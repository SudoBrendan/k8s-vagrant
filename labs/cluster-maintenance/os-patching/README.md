# Lab: OS Patching

Walk-through Operating System patching for all K8s control plane and worker nodes.

## Description

To maintain security of all your nodes, you'll need a patching strategy. With
proper sequencing, you can patch all nodes without downtime of workloads.

## Prerequisites

```sh
cd <TOP>/clusters/ubuntu-1804/simple
./up.sh
```

## Objectives

Using only the [Kubernetes documentation](https://kubernetes.io/docs/home/),
perform system upgrades (not including container runtime / kubernetes binaries)
on all nodes in the cluster without application downtime.

[Solution](./solution/README.md)

## Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple
./down.sh
```

