# Cluster: Simple

A baseline cluster with a single master node and two worker nodes.

## Quick Start

```sh
# provision cluster
./up.sh

# issue commands from control plane node
vagrant ssh u1804-simple-master0
kubectl get nodes
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80
exit

# tear down resources
./down.sh
```

## Default Total Resources

|vCPU|RAM|
|--|--|
|4|4Gb|

## Configurations

Setting environment variables before running `vagrant up` can configure how the
cluster is provisioned. For example:

```sh
# provision bare minimum VMs without doing anything Kubernetes related
INSTALL_BINARIES_MASTERS="N" INSTALL_BINARIES_WORKERS="N" vagrant up
```

Here are the supported options:

|Environment Variable|Description|Dependencies|Default|Override|
|--|--|--|--|--|--|
|`INSTALL_BINARIES_MASTERS`|Install container runtime and all Kubernetes binaries (kubeadm/kubelet/kubectl) on master nodes|None|install binaries|"N"|
|`INITIALIZE_MASTERS`|Run `kubeadm init` to provision the cluster|`INSTALL_BINARIES_MASTERS`|initialize masters|"N"|
|`INITIALIZE_METALLB`|Provision Layer2 configuration for MetalLB, allowing LoadBalancer type Services|`INSTALL_BINARIES_MASTERS`, `INITIALIZE_MASTERS`|do not provision|"Y"|
|`INITIALIZE_NGINX_INGRESS`|Provision Nginx Ingress Controller, allowing creation of Ingress objects|`INSTALL_BINARIES_MASTERS`, `INITIALIZE_MASTERS`, `INITIALIZE_METALLB`|do not provision|"Y"|
|`INSTALL_BINARIES_WORKERS`|Install container runtime and all Kubernetes binaries (kubeadm/kubelet/kubectl) on worker nodes|None|install binaries|"N"|
|`INITIALIZE_WORKERS`|Run `kubeadm join` to add worker nodes to the cluster|`INSTALL_BINARIES_MASTERS`, `INITIALIZE_MASTERS`, `INSTALL_BINARIES_WORKERS`|join workers|"N"|

