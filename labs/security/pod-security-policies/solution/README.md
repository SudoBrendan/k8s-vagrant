# Solution: Enable PodSecurityPolicies

Per the Kubernetes docs, enabling PSPs before you're sure it'll work can be bad news -
you can potentially take down workloads by accidentally not authorizing the
appropriate ServiceAccounts to use the policies you create. This won't actively
take down running Pods, but it will make new Pods of the same spec impossible
to schedule (for example, after upgrading a Deployment), leading to errors in
your Event logs like:

```text
Error creating: pods "foo-f89759699-" is forbidden: unable to validate against any pod security policy: []
```

***With this said, it's extremely important to test and test and test again if you're
enabling PSPs on a cluster already running Pods, especially if it's prod! You'll
also need to work with all your development teams to figure out exactly what
permissions their containers use already and how to create PSPs that work for them
and your organization's security requirements.***

...with that out of the way let's do this!


## Step 1: Configure Privileged PSP

1. SSH into the master control plane node
1. Review the current ServiceAccounts in `kube-system` - these are CRITICAL to get
   right before we set up the API to use the `PodSecurityPolicy` Admission
   Controller. Running `kubectl get sa -n kube-system` gets us quite a list...
   a more helpful command is `kubectl get po -n kube-system -o custom-columns=NAME:.metadata.name,SA:.spec.serviceAccount` to see the accounts actively running system Pods.
1. Review and apply the [privileged policy](./manifests/psp-zz-privileged.yaml) to the cluster
    - Note the use of individual ServiceAccounts by `.metadata.name` in the bindings... we
      shouldn't authorize [all ServiceAccounts](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-binding-examples), because that would authorize the
      SAs used by our Controllers (e.g. the Deployment controller), which
      effectively means anyone capable of creating a Deployment can create a
      privileged Pod - not good! Generally, the only Pods we want to run with
      permissions like this are administrative ones; Pods that are actively
      manipulating their hosts (like `kube-proxy`, which requires a shared host
      network in order to modify `iptables`). If you have a customer that requires
      permissions like this, I'd recommend at a bare minimum giving them their
      own [tainted Node](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
      to run their Pods, that is, if you can't convince them they're wrong and
      their boss signs off on the security risk :)
    - We prefix the psp name with `zz` so it is [resolved appropriately](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#policy-order) compared to
      other PSPs. Generally, you want to put highest privileged policies last
      alphabetically.

## Step 2: Configure Restricted PSP

1. Review and apply the [restricted policy](./manifests/psp-aa-restricted.yaml)
    - Since this policy is very restrictive, I see no issue in allowing all SAs
      access to this policy as a secure "deny-by-default". If someone/something
      (a controller) has access to create Pods, I feel comfortable with them
      creating Pods if it adheres to this policy.

## Step 3: Review RBAC of Policies

1. Run `kubectl get po -A -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,SA:.spec.serviceAccount`
   to list out all serviceAccounts in use for all Pods in the cluster. We need
   to validate all SAs have access to `use` the PSPs we created.
1. For each PSP, NAMESPACE, and SA, run the following: `kubectl auth can-i use podsecuritypolicy/PSP --as=system:serviceaccount:NAMESPACE:SA`.
   Do they return `yes` and `no` as you'd expect? To be clear - this tells us if
   the SA even has *access* to the Policy, not if Pods will pass the policy's
   requirements.

## Step 4: Enable PodSecurityPolicy API Admission Controller

1. To ensure the API can enforce our PSPs during the authorization phase of a
   request, we need to set up a new [Admission Controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) on our API instance.
1. On the master node, edit and save `/etc/kubernetes/manifests/kube-apiserver.yaml`, the
   [static Pod](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)
   definition responsible for running the API instance as a container
   managed by Kubelet. You'll look to edit the `--enable-admission-plugins` flag,
   it'll end up looking something like:

    ```yaml
    [...]
    spec:
      containers:
      - command:
        - kube-apiserver
        - --authorization-mode=Node,RBAC
        - --enable-admission-plugins=NodeRestriction,PodSecurityPolicy
        [...]
    ```

## Step 5: Validate PSP Functionality

1. Review and apply the [nginx Deployment](./manifests/nginx.yaml) to the `default`
   Namespace. This shouldn't successfully schedule, because it doesn't meet the
   requirements of the `restricted` PSP (the only one usable by `system:serviceaccount:default:default`),
   namely, the container runs as UID 0. We can validate this by checking out the
   Events: `kubectl get ev`.
1. Review and apply the [apache Deployment](./manifests/apache.yaml) to the `default`
   Namespace. This should successfully schedule, since the bitnami image used is
   configured to run as UID 1001. We can also validate this in Events: `kubectl get ev`.

## Step 6: Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple
./down.sh
```

## Conclusions

PodSecurityPolicies are a great way to prevent users of your cluster from doing
malicious things either intentionally or unintentionally, or enforcing security
standards for everyone with a few manifests (e.g. require a particular `seccomp`
profile for every container). However, you must use caution when enabling this functionality by
setting RBAC permissions correctly, and you must ensure your development teams
have the policies they need to run their workloads. The former is solved by
automations and auditing, and the later solved by communication. New
ServiceAccounts must have the capability to `use` at least one PSP. Additionally,
you should consider continually auditing what ServiceAccounts have what PSPs
available, and who has access to these ServiceAccounts (and perhaps often missed,
[their Secrets!](https://kubernetes.io/docs/concepts/configuration/secret/#service-accounts-automatically-create-and-attach-secrets-with-api-credentials)). Finally, strong communication
with your developers is a must-have with PSPs; if you don't let people know how
they work or the options available, you'll leave developers irritated and confused
over why their Pods won't schedule. All these consequences ultimately lead to a
more secure cluster. Take the time to do it right! :)

