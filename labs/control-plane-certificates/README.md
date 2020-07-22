# Lab: Control Plane Certificates

Perform a manual certificate rotation for the Kubernetes API server.

## Description

While this is something you'll probably never have to do, it makes sense to
walkthrough a manual certificate rotation on a kubeadm cluster. Walking through
[Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md) has you generate all certificates and kubeconfig files necessary
for all cluster components from scratch, but what if your cluster's already been
provisioned?

## Prerequisites

```sh
cd <TOP>/clusters/ubuntu-1804/simple
./up.sh

# validate
vagrant ssh u1804-simple-master0
kubectl get cs
kubectl get nodes
kubectl version --short
```

## Objectives

Rotate the public/private certificate used for connecting over TLS to the
Kubernetes API.

[Solution](./solution/README.md)

## Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple/
./down.sh
```

