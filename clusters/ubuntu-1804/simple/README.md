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

