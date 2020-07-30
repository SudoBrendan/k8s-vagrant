# TODO

## Vagrant

Create multiple configurations of clusters so people get to see nuances of different
distro installs and Kubernetes configurations:

- [ ] Ubuntu 18.04
    - [X] Simple
    - [ ] Highly Available
- [ ] Ubuntu 20.04
    - [ ] Simple
    - [ ] Highly Available
- [ ] CentOS ??
    - [ ] Simple
    - [ ] Highly Available

## Labs

I want these labs to closely mimic the CKA exam - it's quite rigorous proof you
know your way around Kubernetes... Here's the current [curriculum](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_V1.18.pdf).

### Core Concepts

- [X] Architecture (guided tour of kubeadm cluster)
- [ ] Primitives
    - [ ] stand up a scaled, stateless web app with ingress and TLS
    - [ ] stand up a stateful, clustered database
    - [ ] stand up a scheduled batch process

### Security

- [ ] RBAC Primitives
    - [ ] Configure an application to use a unique ServiceAccount
    - [ ] Configure a ServiceAccount with read rights on the cluster (!!!)
- [ ] Network Policies
    - [ ] Lock down a full stack (cache/web/database) with PNP
- [X] Cluster TLS Certificates
    - [X] Rebuild a component's certificates from scratch, preferably with cfssl
- [ ] Work With Images Securely
    - [ ] Provision a private docker repo in the cluster, stand up Secret for
          authentication for a Namespace
- [ ] Define Security Contexts
    - [ ] Configure a privileged Pod and a locked-down Pod (CAPS)
    - [X] Create and use Pod Security Policies
- [ ] Secure key-value store
    - [ ] Encrypt etcd and validate

### Installation, Configuration, and Validation

- [X] Simple
    - [X] kubeadm install for masters, nodes, CNI, secure communications, master
          e2e tests, node e2e tests
- [ ] Highly Available
    - [ ] kubeadm install for masters, nodes, CNI, secure communications, master
          e2e tests, node e2e tests

### Cluster Maintenance

- [ ] Cluster Upgrades
    - [X] Simple Upgrade
    - [ ] Highly Available Upgrade
- [X] OS Upgrades
- [ ] Backup and Restore
    - [ ] Simple
        - [X] Unencrypted etcd backup/restore
        - [ ] Encrypted etcd backup/restore
    - [ ] Highly Available
        - [ ] Unencrypted etcd backup/restore
        - [ ] Encrypted etcd backup/restore

### Networking

 - [ ] Cluster networking
    - [ ] CNI configuration
    - [ ] Understand node network
    - [ ] Cluster DNS
 - [ ] Service networking
     - [ ] Deploy network load balancer
 - [ ] Ingress rules

### Troubleshooting

 - [ ] Application failure
 - [ ] Control plane failure
 - [ ] Worker node failure
 - [ ] Network failure

### Application Life Cycle Management

 - [ ] Deployments
    - [ ] Updates, rollbacks, scaling
 - [ ] Jobs
    - [ ] Scaling, CronJobs
 - [ ] StatefulSets
    - [ ] Updates, rollbacks, scaling, caveats
 - [ ] Pods
     - [ ] ConfigMap/Secret usage
     - [ ] Self-Healing applications

### Storage

 - [ ] Cluster storage
    - [ ] PersistentVolumes, StorageClasses, PersistentVolumeClaims
 - [ ] Pod storage
     - [ ] Volumes (access modes), configuration through Volumes

### Scheduling

 - [ ] Scheduling Pods
    - [ ] NodeSelector, label selectors, static pods, schedule events, resource limits
 - [ ] DaemonSets
 - [ ] kube-scheduler
    - [ ] Multiple schedulers, configure scheduler, events

### Logging/Monitoring

 - [ ] Cluster components
    - [ ] Monitor / manage logs
 - [ ] Applications
    - [ ] Monitor / manage logs

