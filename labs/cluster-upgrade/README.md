# Lab: Cluster Upgrade

Go through the process of upgrading a Kubernetes cluster's binaries.

## Descripiton

When administering a Kubernetes cluster, you will need to roll new versions of
the Kubernetes binaries to both the control plane and worker nodes to address
security patches and enable new features. Administrators of clusters should
continually patch k8s binaries when they are available. There are myriad ways
to do this depending on how your cluster was provisioned. Cloud providers
(AKS/GKE/EKS) will either automatically update these binaries or have a "click
a button" feature to roll the binaries to all servers at a specific time you
choose.

Kubeadm is an official Kubernetes way to provision clusters, and it also
facilitates upgrades. This lab goes over upgrading a Kubernetes cluster
created by `kubeadm`.

## Prerequisites

```sh
# Provision a single control-plane (non-HA) cluster
cd <TOP>/clusters/ubuntu-1804/simple/
./up.sh

# Validate the cluster version
vagrant ssh u1804-simple-master0
kubectl get cs
kubectl get nodes
kubectl version
```

## Objectives

Using only the [Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/),
upgrade the cluster from it's current version to the next version (following the
[Kubernetes version skew policies](https://kubernetes.io/docs/setup/release/version-skew-policy/)).

[Solution](./solution/README.md)

## Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple/
./down.sh
```
