# Solution: Install Configure Validate Single Control Plane Cluster

This is already
[very well documented](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/),
so I'll leave out quite a few specifics. As an alternative, you can check out
the vagrant configurations for more details.

## Step 1: Binaries

On all nodes, you'll install:

1. container runtime
2. kubeadm, kubelet, kubectl

It's always recommended to hard-code all package versions for these
binaries. After installing, you'll put all these packages "on hold"
in the package manager so you don't accidentally upgrade them unintentionally.

## Step 2: Kubeadm init

On the master node, you'll run `kubeadmin init --pod-network-cidr=X`, where `X`
is the recommended CIDR range for our CNI, here, Calico.

In the final output are several important commands, including kubeconfig
and join commands.

## Step 3: Kubeconfig

Once `kubeadm init` is complete, it prints out next steps, including
moving the root `kubeconfig` into your home directory.

## Step 4: CNI

Once your `kubeconfig` is in place, you can authenticate into the cluster
and issue commands, including setting up a CNI plugin with `kubectl create -f`.

## Step 5: Worker Join

For each worker in the cluster, you can run the `kubeadm join` command printed
in the output of `kubeadm init`, which includes a token that only lasts for
a few hours. If your token expires, you can print a new command with

```sh
kubeadm token create --print-join-command
```

## Step 6: Validate

If everything worked properly, you should be able to...

1. see healthy component statuses (though, componentstatus is getting reworked,
   and there are several
   [GitHub issues](https://github.com/kubernetes/kubernetes/issues/19570) for
   this not working properly on some k8s versions)
    ```sh
    kubectl get cs
    ```
1. see all 3 nodes in `Ready` state:
    ```sh
    kubectl get nodes
    ```
1. test api/etcd/controller-manager/scheduler by creating primitives
    ```sh
    kubectl create deploy nginx --image=nginx
    kubectl scale deploy/nginx --replicas=3
    kubectl expose deploy/nginx --port=80
    ```
1. test inter-Pod and inter-node communication
    ```sh
    # get IP of any Pod in the deployment
    kubectl get po -o wide

    # run tmp Pod to connect to Pod on another node (run it 5x to ensure you
    # get on the opposite node)
    kubectl run bb --image=busybox -it --rm --restart=Never -- hostname -i && wget -O- <IP-OF-POD>
    ```
1. test services
    ```sh
    # get IP of service
    kubectl get svc
    
    # run tmp Pod to validate
    # P.S. - as an aside, you'll never be able to "ping" a Service - it's just
    # a DNS record; you've gotta use something that actually attempts to
    # connect to the endpoint (wget/netcat/etc)
    kubectl run bb --image=busybox -it --rm --restart=Never -- hostname -i && wget -O- <IP-OF-SERVICE>
    ```
1. test DNS
    ```sh
    # Deployment DNS
    kubectl run bb --image=busybox -it --rm --restart=Never -- wget -O- http://nginx
    kubectl run bb --image=busybox -it --rm --restart=Never -- wget -O- http://nginx.default
    kubectl run bb --image=busybox -it --rm --restart=Never -- wget -O- http://nginx.default.svc.cluster.local

    # Pod (Deployment) DNS
    kubectl run bb --image=busybox -it --rm --restart=Never -- wget -O- http://<IP-OF-POD-HYPHENATED>.nginx.default.svc.cluster.local
    ```

## Conclusions

Standing up k8s with `kubeadm` is pretty simple! It comes down to a few commands,
and most of what you need is found in the output of `kubeadm init` once you get to
that point. The install guides in the official k8s docs are a great resource and
very easy to understand, so run through this a few times to get really comfortable
with the process. Additionally, using `tmux` or some other tool capable of
having synchronized panes (performing the same command in multiple terminals) is
a huge help for installing the binaries and joining multiple nodes to the cluster
at once. You might also check out creating
[kubeadm config files](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/)
to stand up your clusters without remembering a bunch of custom options.

