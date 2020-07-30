# Solution: OS Patching

Performing system upgrades is likely something you want to automate, but let's
do everything manually as an exercise.

## Node Patching

For all nodes (you likely want to start with a worker node just to be sure updates
don't murk something horribly):

1. Drain the Node of all possible Pods
    ```sh
    # on control plane node (or anywhere you can access kubectl)
    kubectl get nodes
    # this command can fail, pay attention if it does!! https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/#the-eviction-api
    kubectl drain NODE_NAME --ignore-daemonsets
    ```
1. Hop into the node and perform system upgrades
    ```sh
    vagrant ssh <NODE_NAME>

    sudo -i

    # list held packages - should include all kube* binaries and container runtime
    apt-mark showhold

    # patch everything not in that list, requires confirmation
    apt-get update && apt-get upgrade

    # informational only; view logs for patched software versions
    awk '$3=="upgrade"' /var/log/dpkg.log

    # optional - only if some patches require a restart
    reboot
    ```
1. Allow workloads to again be scheduled to this node
    ```sh
    # validate node state
    kubectl get node NODE_NAME
    kubectl describe node NODE_NAME

    # allow scheduling again
    kubectl uncordon NODE_NAME
    ```

## Conclusions

Patching is relatively straightforward, just be sure (as with ANY maintenance
procedure on any node...) that you're draining the Node so you don't interrupt
your workloads! To ensure workloads in the cluster (especially stateful ones!)
are capable of handling any node outages, make sure your customers know about and use
[PodDisruptionBudgets](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
when necessary. If draining a node fails due to a PDB, you'll need to work directly
with the application owner and make a decision on when/how to get that Pod evicted
to perform upgrades. As a caveat, this is one great reason to have a useful
[labeling strategy](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
for all primitives. I'd recommend including team contact info (mailing list/on-call
number) in a standardized [annotation](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)
as well. With this, you can easily migrate into an automated patching strategy -
one that automatically notifies users if their Pods are preventing cluster
maintenance. Slick!

If you've already got an automated patching strategy and only
want to facilitate kubernetes-safe draining/rebooting/uncordoning of all your
nodes in the cluster, check out
[Kubernetes Reboot Daemon](https://github.com/weaveworks/kured) by WeaveWorks.

