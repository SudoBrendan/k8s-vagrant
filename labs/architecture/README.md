# Lab: Architecture

## Description

Identify all key components and configuration files for a `kubeadm` cluster.

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

1. Identify required machines to run a single control-plane cluster
1. Identify network requirements to run a single control-plane cluster
1. Identify control plane components, how they run, and how they are configured
1. Identify worker node components, how they run, and how they are configured
1. Identify required cluster add-ons, how they run, and how they are configured
1. Identify optional cluster add-ons, how they run, and how they are configured

[Solution](./solution/README.md)

## Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple/
./down.sh
```

