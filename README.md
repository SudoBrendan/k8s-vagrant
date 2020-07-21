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
through [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Additionally,
the following plugins should be installed:

```sh
vagrant plugin install vagrant-scp
```

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

To go through a few different administrative exercises, check out the [labs](./labs).

## Disclaimer

While I do hope that these environments and labs are helpful to you on your journey
to implementing and administering Kubernetes (it really is an awesome tech stack!),
this repository and it's contents should never be a substitute for doing your
own research on any given topic, and definitely are not suitable for copy-pasta
solutions in any of your current or future environments. They are provided in
good faith to give you a path to learn in isolated environments; nothing else.

Before doing anything with this repository, please read the [LICENSE](LICENSE).

## Contribute

Have an addition or an edit to contribute? Wonderful! Submit me an Issue
or a PR! :) Please keep things relevant directly to the vagrant configurations
or the labs.

Check out the [contribution](./contribute/README.md) guide for more information.


## Credits

Some vagrant configurations were based on work by others, namely [Alex](https://blog.exxactcorp.com/building-a-kubernetes-cluster-using-vagrant/) and [Kim](https://github.com/wuestkamp/cka-example-environments). Thank you for your contributions to Open Source!

