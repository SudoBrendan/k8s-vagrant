# Solution: Upgrade Cluster

This procedure is [very well documented](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/), but here's my solution for the
vagrant cluster if you get stuck with that:

## Step 1: Control Plane

1. Login to the control plane node: `vagrant ssh u1804-simple-master0`
1. [Optional] Take a [backup of control plane certificate data](../../control-plane-restore/README.md)
    and put it somewhere safe (ideally, you're already doing this automatically
    on a schedule). `kubeadm` automatically backs up etcd and static pod
    manifests, so you don't need to worry as much about those.
1. Validate the cluster is up and working
    ```sh
    kubectl get cs
    kubectl get nodes
    ```
1. Validate binary versions in the cluster
    ```sh
    kubectl version
    ```
1. Remove all running workloads and prevent new workloads from being scheduled
    ```sh
    kubectl drain u1804-simple-master0 --ignore-daemon-sets
    ```
1. Swap to root user
    ```sh
    sudo -i
    ```
1. Validate binary versions in package manager
    ```sh
    apt-cache policy kubeadm
    apt-cache policy kubelet
    apt-cache policy kubectl
    ```
1. Find available versions in package manager
    ```sh
    apt-get update
    apt-cache madison kubeadm
    ```
1. Update kubeadm binary
    ```sh
    # using version based on skew policy...
    apt-mark unhold kubeadm && apt-get install kubeadm=X.Y.Z-00 && apt-mark hold kubeadm
    ```
1. Upgrade cluster
    ```sh
    kubeadm upgrade plan
    kubeadm upgrade apply vX.Y.Z
    ```
1. [Optional] Take a backup of your updated certificates directory and place it
   somewhere safe
1. If required, update the CNI plugin. The `simple` cluster by default uses
   [Calico](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises).
    ```sh
    # requires run as non-root!
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    ```
1. Update kubectl and kubelet
    ```sh
    apt-mark unhold kubelet kubectl && apt-get install kubelet=X.Y.Z-00 kubectl=X.Y.Z-00 && apt-mark hold kubelet kubeadm
    systemctl daemon-reload
    systemctl restart kubelet
    ```
1. Verify upgrade of control plane node
    ```sh
    # requires run as non-root!
    kubectl get cs
    kubectl get nodes
    kubectl version --short
    ```
1. Allow Pods to be scheduled again
    ```sh
    kubectl uncordon u1804-simple-master0
    ```

## Step 2: Worker Nodes

For each worker node in the cluster, perform the following, one at a time:

1. Remove running workloads and prevent new ones from scheduling
    ```sh
    # from control plane node
    kubectl drain u1804-simple-workerX --ignore-daemon-sets
    ```
1. Login to the worker node: `vagrant ssh u1804-simple-workerX`
1. Swap to root user
    ```sh
    sudo -i
    ```
1. Validate binary versions in package manager
    ```sh
    apt-cache policy kubeadm
    apt-cache policy kubelet
    apt-cache policy kubectl
    ```
1. Find available versions in package manager
    ```sh
    apt-get update
    apt-cache madison kubeadm
    ```
1. Update Kubeadm
    ```sh
    # using version based on skew policy...
    apt-mark unhold kubeadm && apt-get install kubeadm=X.Y.Z-00 && apt-mark hold kubeadm
    ```
1. Update Kubelet config
    ```sh
    kubeadm upgrade node
    ```
1. Update kubectl and kubelet
    ```sh
    apt-mark unhold kubelet kubectl && apt-get install kubelet=X.Y.Z-00 kubectl=X.Y.Z-00 && apt-mark hold kubelet kubeadm
    systemctl daemon-reload
    systemctl restart kubelet
    ```
1. Allow Pods to be scheduled again
    ```sh
    kubectl uncordon u1804-simple-workerX
    ```
1. Verify
    ```sh
    # on control plane node
    kubectl get nodes
    ```

## Conclusions

Upgrading a cluster is a very involved process. You'll likely want to find a
way to partially automate it as your clusters grow past a few nodes, but you'll
always want to keep up with the Kubernetes [patch notes](https://kubernetes.io/docs/setup/release/notes/)
and [releases](https://github.com/kubernetes/kubernetes/releases) for details,
as some upgrades will introduce breaking changes like deprecating API objects.
Good monitoring and alerting is a must-have during upgrades and taking a backup
is also recommended.
