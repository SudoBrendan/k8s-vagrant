# K8s Vagrant Labs

Labs are designed to walk through common Kubernetes administrator tasks
in the [vagrant clusters](../clusters), which are provisioned using
`kubeadm`. The lab structure is based on concepts found in the
[CNCF CKA Curriculum](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_V1.18.pdf).

## Index

- Core Concepts
    - [Cluster Architecture](./core-concepts/architecture/README.md)
- Security
    - [Cluster TLS Certificates](./security/control-plane-certificates/README.md)
    - [Create and Use Pod Security Policies](./security/pod-security-policies/README.md)
- Installation, Configuration, and Validation
    - [Single Node Cluster](./installation-configuration-validation/single-cp-cluster/README.md)
- Cluster Maintenance
    - [Upgrade](./cluster-maintenance/cluster-upgrade/README.md)
    - [Operating System Patching](./cluster-maintenance/os-patching/README.md)
    - [Backup and Restore](./cluster-maintenance/control-plane-restore/README.md)
