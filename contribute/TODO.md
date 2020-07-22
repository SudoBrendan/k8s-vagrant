# TODO

## Vagrant

Create multiple configurations of clusters so people get to see nuances of different
distro installs and Kubernetes configurations:

- [ ] Ubuntu 18.04
    - [X] Simple
    - [ ] Highly Available
- [ ] Ubuntu 20.04
    - [X] Simple
    - [ ] Highly Available
- [ ] CentOS ??
    - [ ] Simple
    - [ ] Highly Available

## Labs

I want these labs to closely mimic the CKA exam - it's quite rigorous proof you
know your way around Kubernetes... Here's the current [curriculum](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_V1.18.pdf).

### Core Concepts

- [ ] Architecture (guided tour of kubeadm cluster)
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
- [ ] Cluster TLS Certificates
    - [ ] Rebuild a component's certificates from scratch, preferably with cfssl
- [ ] Work With Images Securely
    - [ ] Provision a private docker repo in the cluster, stand up Secret for authentication for a Namespace
- [ ] Define Security Contexts
    - [ ] Configure a privileged Pod and a locked-down Pod (CAPS)
    - [X] Create and use Pod Security Policies
- [ ] Secure key-value store
    - [ ] Encrypt etcd and validate

### Installation, Configuration, and Validation

- [ ] Simple
    - [ ] kubeadm install for masters, nodes, CNI, secure communications, master e2e tests, node e2e tests
- [ ] Highly Available
    - [ ] kubeadm install for masters, nodes, CNI, secure communications, master e2e tests, node e2e tests

### Cluster Maintenance

- [ ] Cluster Upgrades
    - [ ] Simple Upgrade
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

 - [ ]

### Troubleshooting

 - [ ] 

### Application Lifecycle Management

 - [ ] 

### Storage

 - [ ] 

### Scheduling

 - [ ] 

### Logging/Monitoring

 - [ ] 
