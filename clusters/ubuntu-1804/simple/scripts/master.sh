#/bin/bash

set -e

apt-get update && apt-get install -y etcd-client

echo "=============================="
echo "KUBEADM INIT"
echo "=============================="
kubeadm init --kubernetes-version="${K8S_VERSION}" --apiserver-advertise-address="${K8S_APISERVER_ADDRESS}" --pod-network-cidr="${K8S_POD_NETWORK_CIDR}"

mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

echo "=============================="
echo "DEPLOY CNI"
echo "=============================="
su - vagrant -c "kubectl create -f ${CNI_MANIFEST_URL}"

echo "=============================="
echo "SAVE WORKER JOIN COMMAND"
echo "=============================="
kubeadm token create --print-join-command > /vagrant/tmp/joincluster-worker.sh
