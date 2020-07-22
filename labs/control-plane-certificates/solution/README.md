# Solution: Control Plane Certificates

Since Kubernetes The Hard Way is one of the most common ways of learning about
K8s certificates, I'll follow a similar procedure for rolling certificates by
using the same toolset (cfssl/cfssljson).

## Step 1: Install Tools

On the K8s master node:

```sh
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64 -o cfssl
chmod +x cfssl
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64 -o cfssljson
chmod +x cfssljson

sudo mv cfssl* /usr/local/bin/
```

## Step 2: Find Our Certs

To discover what certs are used for TLS on our API, we can check the static pod
manifest `kubeadm` created on the master node:

```sh
ls /etc/kubernetes/manifests
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

We'll see in the configuration of the container's command the following options:

```text
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt
--tls-private-key-file=/etc/kubernetes/pki/apiserver.key
```

These two files are what we need to roll.

## Step 3: Create CA Config Profile

This can be a bit confusing - the [official docs](https://kubernetes.io/docs/concepts/cluster-administration/certificates/#distributing-self-signed-ca-certificate)
show creating a new CA file using cfssl... While you'd need to do this for a
brand new cluster, `kubeadm` already initialized several.

Our solution then, will involve creating a `ca-config.json` that *mocks the
CA we already have that was used to sign our current certificate*. You can generate a
reasonable default config with `cfssl print-defaults config`, but that'll give
you two profiles; one for server, and another for client. Our profile (a CA),
will perform both server and client auth.

To start, on our master node, let's make a temp working directory to keep things
clean:

```sh
mkdir ~/certs
cd ~/certs
```

Our `~/certs/ca-config.json` looks like:

```json
{
    "signing": {
        "default": {
            "expiry": "168h"
        },
        "profiles": {
            "kubernetes": {
                "expiry": "8760h",
                "usages": [ "signing", "key encipherment", "server auth", "client auth" ]
            }
        }
    }
}
```

## Step 4: Create kube-apiserver CSR

To figure out the current CN and Hostnames used in our certs, we can use cfssl:

```sh
cfssl certinfo -cert /etc/kubernetes/pki/apiserver.crt
```

We care about a few fields:

|Field|CFSSL Meaning|My Output|
|--|--|--|
|`.subject.common_name`|`CN` in our CSR config|`kube-apiserver`|
|`.sans`|`hosts` that should appear in our CSR config|`[ "u1804-simple-master0", "kubernetes", "kubernetes.default", "kubernetes.default.svc", "kubernetes.default.svc.cluster.local", "10.96.0.1", "10.0.1.10"]`|
|`.sigalg`|gives us a clue about the algorithm to use when generating keys in our CSR config|`SHA256WithRSA`|

As a helpful guide, we can generate a reasonable stub file with `cfssl print-defaults csr`.

With all this information in mind, we can create `~/certs/apiserver-csr.json`:

```json
{
    "CN": "kube-apiserver",
    "hosts": [
        "u1804-simple-master0",
        "kubernetes",
        "kubernetes.default",
        "kubernetes.default.svc",
        "kubernetes.default.svc.cluster.local",
        "10.96.0.1",
        "10.0.1.10"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
```

## Step 5: Generate Certs

Now that we've got a CA public and private key (again, already present - thanks
`kubeadm`!), a CA configuration profile, and CSR config, we can generate a new cert:

```sh
cfssl gencert \
  -ca=/etc/kubernetes/pki/ca.crt \
  -ca-key=/etc/kubernetes/pki/ca.key \
  -config=ca-config.json \
  -profile=kubernetes \
  apiserver-csr.json | cfssljson -bare apiserver
```

This'll create two files:

```text
apiserver.pem
apiserver-key.pem
```

Now, you might be thinking "great, this gave me PEM format and the files in /etc
are .crt and .key - I've gotta format this with openssl"... but not so fast! Let's
check our /etc files:

```sh
cat /etc/kubernetes/apiserver.crt
cat /etc/kubernetes/apiserver.key
```

I see

```text
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
```

and

```text
-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----
```

respectively. If we view our current files, we'll see we've already got the
format we need:

```sh
cat ~/certs/apiserver.pem
cat ~/certs/apiserver-key.pem
```

Nice!

## Step 6: Rotate Certs

Next, let's backup and replace our certs:

```sh
sudo -i
cd /etc/kubernetes/pki

cp ./apiserver.crt ./apiserver.crt.old
cp ./apiserver.key ./apiserver.key.old

cp ~/certs/apiserver.pem ./apiserver.crt
cp ~/certs/apiserver-key.pem ./apiserver.key
```

Now, the last thing to do is restart our API server Pod; we can do this by restarting
kubelet:

```sh
systemctl restart kubelet
```

## Step 7: Validate

If everything went well, we should be able to hit the API and not get certificate
errors - you can test this with any `kubectl` command:

```sh
kubectl get cs
```

As always, don't forget to tear down your cluster once you've completed the lab.

## Conclusions

Certificates can be difficult to grasp, especially for people with a limited
networking background. Take the time to analyze the certificates already generated
by `kubeadm`. I'd recommend copy-pasting information directly instead of typing
manually to reduce errors - a single character off, and your certs will fail.
As long as you use the appropriate CA, CN, Organization (in cases like `kubelet`,
 `kube-scheduler`, and others), and hostnames to generate your certs, you
shouldn't have much issue, just be sure you take backups!

If you haven't already, I'd highly recommend a runthrough of the Kubernetes The
Hard Way certificate/kubeconfig sections to see exactly what certificates are
required when provisioning a Kubernetes cluster (pay special attention to the Organization
section of each CSR). Running through that a few times will really solidify
this lab's concepts. I'd also recommend running through that
lab by manually typing everything the first time if you don't have previous
experience with certificate management! You're likely to fat-finger something,
meaning you'll get to experience some certificate errors and learn to troubleshoot
them.

