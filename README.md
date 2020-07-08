# Vagrant Kubernetes Labs

This repo contains a locally-deployable Kubernetes cluster using Vagrant VMs and
bootstrapping scripts. It's intended to be used to practice Kubernetes administrative
tasks.

## Prerequisites

### Hardware

Generally, Vagrant creates control plane nodes (2 vCPU, 2GB RAM) and worker
nodes (1 vCPU, 2 GB RAM). Ensure whatever hardware you're using can handle
provisioning these virtual resources, and once you're done, you likely want to
tear down the stack so it stops running in the background.

### Software

All clusters are built with [Vagrant](https://www.vagrantup.com/docs/installation)
through [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

## Quick Start

```sh
# navigate to cluster you want
cd clusters/ubuntu-1804/simple

# create the cluster
./up.sh

# ssh into the control plane
vagrant ssh u1804-simple-master0

# interact with the cluster
kubectl get cs
kubectl get nodes -o wide
kubectl create deployment nginx --image=nginx
kubectl expose deploy/nginx --port=80
kubectl get po -o wide
kubectl get svc

# logout of the VM
exit

# tear down to free up your machine's resources
./down.sh
```

## Labs

To go through a few different administrative exercies, check out the [labs](./labs).

## Contribute

Have a new type of cluster or administrative lab to add? Submit me a PR! :)

## Credits

Some vagrant configurations were based on work by others, namely [Alex](https://blog.exxactcorp.com/building-a-kubernetes-cluster-using-vagrant/) and [Kim](https://github.com/wuestkamp/cka-example-environments). Thank you for your contributions to Open Source!
