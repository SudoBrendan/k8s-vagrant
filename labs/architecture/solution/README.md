# Solution: Architecture

Understanding the basics of a Kubernetes cluster can be a bit confusing because
there are many ways to stand up a cluster, and the Kubernetes docs don't always
differentiate which components are always required, sometimes required depending
on your hosting environment, and sometimes required depending on the workloads
you plan on running in the cluster.

Let's walk through the cluster provisioned in our Vagrant VMs and the components
on each installed by `kubeadm`.

## Step 1: Compute Requirements

A common misconception about Kubernetes is that it's a cloud-specific technology.
In fact, as of this writing, even the [official component diagram](https://kubernetes.io/docs/concepts/overview/components/) indicates
that cloud components are in every cluster! This is false. Kubernetes is a set
of free and [open-source](https://github.com/kubernetes/kubernetes) software
that's used to manage any set of compute resources (bare-metal, VMs in any
cloud, edge compute, a dev machine, etc) and make it available for running
containerized workloads. In fact, Kubernetes is not far off from a "cloud"
itself! It provides an API and set of automations to run containerized
workloads "as a service" on compute you dedicate to it.

To provision a Kubernetes cluster, you only need one machine (which could be used to install
ALL Kubernetes components), but in this cluster we've provisioned several VMs
for a separation of concerns: one set of machines will be responsible for managing
the API and automations to manage everything else ("Control Plane" or "Master" nodes),
and another set will run our "real" workloads like websites, build servers, databases,
you name it ("Worker" nodes). While it is possible (and encouraged for production
scenarios) to run the control plane in high-availability, the cluster we've got
only has a single server to run our control plane: `u1804-simple-master0`. We've
also provisioned and registered two worker nodes: `u1804-simple-worker0` and
`u1804-simple-worker1`.

## Step 2: Network Requirements

There's a few networking requirements we've got to think about when provisioning
our cluster:

1. We need a unique range of IPs for our compute resources (here, vagrant VMs)
1. We need a unique range of IPs for our
   ([unstable](https://kubernetes.io/docs/concepts/services-networking/service/#motivation))
   containers
   ([Pods](https://kubernetes.io/docs/concepts/workloads/pods/))
1. We need a unique range of IPs for our (stable) cluster network
   ([Services](https://kubernetes.io/docs/concepts/services-networking/service/))

If you check out the `Vagrantfile` for our cluster, you'll find the IPs of each
VM has been hard-coded in the `10.0.1.X` range for both control plane and
worker nodes. All compute resources in a single cluster need to have network
connectivity, so ensure there's no firewalls getting in your way! There's
also a special CIDR set for our Pod network - `192.168.0.0/16`. For our cluster
network, we use the
[default](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)
range, currently `10.96.0.0/12`.

We'll talk a little more about how this networking is configured below.

## Step 3: Control Plane Components

All Kubernetes clusters require at a minumum the following components:

1. `kube-apiserver` - An endpoint for the API where we can interact with the
   cluster
1. `etcd` - A distributed key:value datastore used for all cluster persistence 
1. `kube-scheduler` - loop/event automation responsible for finding appropriate
   nodes to run Pods
1. `kube-controllermanager` - loop/event automation responsible for ensuring
   the desired state of Pods given other API primitives (e.g. a Deployment
   scaled to 3 means we should always have 3 Pods)

Traditionally, these components would be installed and managed as a daemon by
the operating system (`systemd`), but `kubeadm` actually provisions these components
as Pods themselves. To understand how Kubernetes can "run itself" like this,
you have to understand a bit more about the software Kubernetes uses to run
containers: `kubelet`. Once a Pod is scheduled to a given node in the cluster,
`kubelet` is responsible for absolutely everything else about the workload:
pulling container images, mounting persistent volumes, setting up the Pod's
network, gathering metrics, getting logs, restarting on failures, etc, etc.
By design, `kubelet` is standalone to create a scalable, distributed way of
running containers. In fact, you can install `kubelet` on a machine without
any control plane connected to it, if you were fine with performing manual
upgrades and disaster recovery of Pods between nodes. To learn more about
this design pattern, I'd recommend
[this explaination by Saad Ali](https://www.youtube.com/watch?v=ZuIQurh_kDk).

Long story short: we can use `kubelet` (managed by `systemd`) to run Pods
without the control plane, so `kubeadm` configures what are called
[static Pods](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)
for each component on each control plane node, and as long as `kubelet` is
working, our control plane is too. We can find these manifests on our master at
`/etc/kubernetes/manifests` - the
[default](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
configuration for `kubelet`. All of these Pods are configured to run in the
`kube-system` namespace, so only cluster administrators have access.

I'd recommend walking through each of these static Pod definitions to see the
requirements of each component, namely TLS certificates, container network
requirements, container privilege requirements, container host access,
kubeconfig files (used to authenticate into the API), and any links to external
configuration files. You should also become familiar with the `kubelet`
configuration in `systemd` found in `/etc/systemd/system/`.

If you want a completely detailed walkthrough of standing up this entire stack
by hand, do a runthrough of
[Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way);
I'd highly recommend it. Just note that KTHW is a walkthrough on GCP, if you
have access to another cloud, there are alternate versions on GitHub. If you'd
rather do everything locally, there's a Vagrant version too!

## Step 4: Worker Node Components

As mentioned above, we need nodes capable of running our containerized workloads
that are identically configured to increase fault tolerance (we want Pods to
easily hop between servers in case one goes down). To achieve this, we need
three components: an [OCI compliant](https://opencontainers.org/) container
runtime (this cluster uses `docker`), `kubelet` to transform Pod specifications
into running containers, and `kube-proxy` to maintain our Service network.

We already talked a lot about `kubelet` above, so let's talk about `kube-proxy`
(which, by the way, is also installed on all our control plane nodes).
`kube-proxy` is actually a misnomer; it's not a proxy at all (though, it used
to be). `kube-proxy` currently maintains routes for our cluster (Service)
network by directly modifying the node's `iptables`. That is to say, if we
have a Service in our cluster with IP 10.96.0.1, we'll find a route to Pods
backing that Service in our node's `iptables` configuration. Whenever a Pod
changes nodes (for disaster recovery, etc), `iptables` is updated on all
nodes by each respective node's `kube-proxy` instance. You can read more
about it in the [docs](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/).
`kubeadm` clusters run `kube-proxy` on all master and worker nodes as Pods
using a DaemonSet found in `kube-system`.

## Step 5: Required Add-Ons

`kube-proxy` manages our Service network, but how do Pods communicate with
each other, especially across nodes? One option would be to use NAT for
all packets addressed to Pods, but an alternative is to use a
[CNI](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network),
which gives us a faster network and potentially more security options as well.

Kubernetes needs a CNI to work properly, nodes won't successfully join
the cluster without a CNI installed. The current cluster uses Calico,
which allows us to use Pod Network Policies (some CNIs won't!). Kubeadm
clusters offer full flexibility in CNI choice because they run vanilla
Kubernetes; other types of clusters (especially cloud-managed ones
like AKS/EKS/GKE) can be much more limiting.

## Step 6: Optional Add-Ons

`kubeadm` installed one very important optional add-on for us:
cluster DNS via `CoreDNS` (named `kube-dns` for backwards compatibility).
You'll find it provisioned as a Deployment in the `kube-system` namespace.
Adding DNS makes Services resolvable by `.metadata.name` anywhere in the
cluster. For example, if I have two web services in the same Namespace 
`backend` and `frontend` with their own respective Services, my `backend` app
can resolve my `frontend` app at `http://frontend` without any additional work.
Services in different Namespaces can be resolved at
`<service-name>.<namespace-name>`, or at the complete domain
`<service-name>.<namespace-name>.svc.cluster.local`.

Some Pods also get DNS, but only when managed by a Deployment or DaemonSet
object. These Pods resolve at
`<pod-ip-periods-replaced-with-hyphens>.<deployment-name>.<namespace-name>.svc.cluster.local`,
while it might seem odd to include the IP address in the DNS record, this could
be useful in reverse DNS lookups to figure out where a particular Pod lives if
the only thing you've got is an IP and a network route.

`kubeadm` is quite minimalistic, so no other add-ons have been installed in this
cluster, but there's plenty more a production-ready cluster might have:

1. Logging/Monitoring/Alerting: something to aggregate logs of cluster components,
   workloads, and servers in the cluster in a single stateful location and notify
   admins and/or devs when something is wonky
1. Ingress Controller: allowing us to use Ingress objects (layer 7 loadbalancer)
1. Layer 4 Loadbalancer: expose raw TCP (databases/caches/etc) out of the
   cluster by IP (as opposed to the default NodePort Service)
1. Mesh Network: if your workloads include microserice architecture, mesh networking
   can improve your workflows and provide advanced networking features
1. Dashboard: an alternate to just using `kubectl`, you can interact with
   the cluster via a website
1. Storage Classes: drivers to manage underlying storage for PersistentVolumes
   bound to PersistentVolumeClaims

## Conclusions

`kubeadm` clusters give us an easy way to provision a bare-bones cluster
with control plane and worker nodes without any cloud interaction which
mostly relies on `kubelet` instead of traditional process managers like
`systemd`. The only addons are for a minimalistic network setup, and
extending past that requires other efforts by administrators.
