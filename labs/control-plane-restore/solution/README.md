# Solution: Control Plane Restore

The main points to know about backup/restoration of a control plane node are:

1. What to backup (and when):
    - all TLS certificates used by control plane components (once per upgrade, or whenever you roll them manually)
    - etcd key-value store (regularly)
    - any custom static Pod definitions, for example, maybe a second scheduler
      or modifications to the api server, like enabling new Admission Controllers
      (the `simple` cluster has none of these, so we don't do this here -
      backup/restore would be identical to the `pki` directory)
1. Restored node requirements (so certs are valid):
    - IP must be identical
    - Hostname must be identical

## Backup

This solution showcases a single snapshot in time we'll restore. A common prod-ready
strategy is to perform these backup actions automatically, like with a CronJob.

```sh
sudo -i

# create backup directory in shared vagrant dir
mkdir -p /vagrant/tmp/backup
mkdir -p /vagrant/tmp/backup/etcd

# backup certs dir
cp -a /etc/kubernetes/pki /vagrant/tmp/backup

# backup static pod manifests
cp -a /etc/kubernetes/manifests /vagrant/tmp/backup

# save etcd snapshot using same image as /etc/kubernetes/manifests/etcd.yaml
docker run --rm -e "ETCDCTL_API=3" -v /vagrant/tmp/backup/etcd:/backup/etcd -v /etc/kubernetes/pki/etcd:/etc/kubernetes/pki/etcd --network host k8s.gcr.io/etcd:3.4.3-0 /bin/sh -c "etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /backup/etcd/snapshot.db"
```

## Destroy

Once we've backed up our certs and etcd, we'll simulate a control plane failure
by destroying the vagrant vm:

```sh
vagrant destroy u1804-simple-master0
```

## Reprovision

```sh
INITIALIZE_MASTERS="N" vagrant up
```

## Restore

Once our node is back online with our container runtime and all required binaries,
we can provision our node identically to how vagrant did it before, but we've got
to restore our files first, and add an extra flag to `kubeadm init` that allows
us to use our backup:

```sh
sudo -i

# restore certs
cp -a /vagrant/tmp/backup/pki /etc/kubernetes

# restore etcd data dir
mkdir -p /var/lib/etcd
docker run --rm -e ETCDCTL_API=3 -v /vagrant/tmp/backup/etcd:/backup/etcd -v /var/lib/etcd:/var/lib/etcd k8s.gcr.io/etcd:3.4.3-0 /bin/sh -c "etcdctl snapshot restore '/backup/etcd/snapshot.db'; mv ./default.etcd/member/ /var/lib/etcd/"

# kubeadm init
kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd --kubernetes-version=1.18.4 --apiserver-advertise-address=10.0.1.10 --pod-network-cidr=192.168.0.0/16

# copy kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# restore static pods
cp -a /vagrant/tmp/backup/manifests /etc/kubernetes
systemctl restart kubelet
```

## Validate

Once our `init` command completes, we've successfully restored the cluster! We
can validate with a few commands:

```sh
kubectl get cs
kubectl get nodes
kubectl get po -A
```

## Conclusions

Understanding how backup/restore procedures work in Kubernetes is probably the
most important skill an administrator can have. If a control plane node dies
(especially if it's the only one!) you don't immediately bring down all your apps
in the cluster, but you prevent every other Kubernetes operation (disaster recovery,
scheduling new workloads, etc) from functioning. Restoring quickly will keep your
developers happy and save you from some MASSIVE headaches. You should practice
backup/restore procedures often so you're prepared when disaster strikes.

It's important to note that this solution might not have backed up everything required
for a complete restore, including things like custom kubelet configuration files (if any).
Since these were left as their defaults in the initialization of the cluster, they were
not included here. While you create and modify your cluster, you should create workflows
for recording what changes require updates to your backup/restore procedures. A
decent catch-all can be to do a complete VM backup/restore.

As a side note, I'd recommend learning about [GitOps](https://www.weave.works/technologies/gitops/)
as a supplemental strategy for distributed cluster disaster recovery - if you
save all your manifests in git, you can restore or migrate an entire cluster
nearly effortlessly by re-uploading all your documents to a new API. An
interesting strategy, but requires every individual team to buy-in. I wouldn't suggest
using GitOps as a standalone alternative to the backup strategy outlined here.
