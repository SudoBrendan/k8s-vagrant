# Lab: Enable PodSecurityPolicies

Go through the process of setting up PodSecurityPolicies in a kubeadm cluster.

## Description

PodSecurityPolicies allow administrators of a cluster to set up an offering of
allowable security configurations for Pods in the cluster. For example, you can
restrict privileged containers, deny use of container host resources (filesystems,
ports, etc), or refuse to run containers as certain UIDs on hosts. Enabling
PSPs should be a consideration when [securing your cluster](https://kubernetes.io/docs/concepts/security/overview/#cluster-applications). Check out [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
for some baseline concepts for policies.

## Prereq

```sh
# provision cluster
cd <TOP>/clusters/ubuntu-1804/simple/
./up.sh

# validate
vagrant ssh u1804-simple-master0
kubectl get cs
kubectl get nodes
kubectl version --short
```

## Objectives

Using only the [Kubernetes documentation](https://kubernetes.io/docs/concepts/policy/pod-security-policy/),
create `privileged` and `restricted` PodSecurityPolicies for the cluster that
are only authorized for use by the appropriate service accounts in the `kube-system` and
`default` namespaces. Validate your permissions, then reconfigure the Kubernetes
API to use PodSecurityPolicies while authorizing requests.

[Solution](./solution/README.md)

## Tear Down

```sh
cd <TOP>/clusters/ubuntu-1804/simple/
./down.sh
```

