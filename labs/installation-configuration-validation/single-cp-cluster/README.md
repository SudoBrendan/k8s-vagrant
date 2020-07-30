# Lab: Install Configure Validate Single Control Plane Cluster

Before you can do anything with Kubernetes, you need to set it up!

## Description

This lab outlines how to create a single control plane cluster using
`kubeadm`.

## Prerequisites

```sh
# provision all baseline VMs
cd <TOP>/clusters/ubuntu-1804/simple
INSTALL_BINARIES_MASTERS="N" INSTALL_BINARIES_WORKERS="N" ./up.sh
```

## Objectives

Using only the [Kubernetes documentation](https://kubernetes.io/docs/home/),
install, configure, and validate all necessary components on the following
machines to create a single control plane cluster using `kubeadm` on the
vagrant machines created:

```text
u1804-simple-master0
u1804-simple-worker0
u1804-simple-worker1
```

Cluster Specifications:
1. Docker Runtime: 19.03
2. Kubernetes Version: latest
3. CNI: Calico

[Solution](./solution/README.md)

## Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple
./down.sh
```

