# Lab: Control Plane Restore

Take backups of cricial control plane data, then restore a completely destroyed
cluster.

## Description

This scenario is the absolte worst case: The single master node has failed...
While our workloads are still functional (for now!), it's up to us to restore
the cluster so our control plane functionality resumes as if nothing had
happened.

## Prereq

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

1. Navigate to the cluster directory
    ```sh
    cd <TOP>/clusters/ubuntu-1804/simple
    ```
1. Find and record the IP/Hostname of the current master node
    ```sh
    # you'll see a `127.X.X.X` address; ignore it
    vagrant ssh u1804-simple-master0 -c "hostname -i; hostname"
    ```
1. Take a backup of all information required to restore the master node, I'd recommend
   putting this data in the shared `/vagrant/` directory, which will persist after
   the vm is destroyed.
1. Take down the master node manually to simulate a complete outage
    ```sh
    vagrant destroy -f u1804-simple-master0
    ```
1. Provision a new master node (must have the same IP/Hostname of the old one)
    ```sh
    INITIALIZE_MASTERS="N" vagrant up
    ```
1. Restore the control plane node from the backup

[Solution](./solution/README.md)

## Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple/
./down.sh
```

