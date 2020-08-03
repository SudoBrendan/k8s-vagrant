#/bin/bash

set -e

echo "=============================="
echo "ADMIN TOOLS"
echo "=============================="

echo "ETCDCTL"
apt-get update && apt-get install -y etcd-client

echo "HELM"
tdir=$(mktemp -d)
pushd $tdir
    helm_version="3.2.4"
    helm_arch="linux-amd64"
    wget https://get.helm.sh/helm-v${helm_version}-${helm_arch}.tar.gz
    tar -xzvf ./helm-v${helm_version}-${helm_arch}.tar.gz
    cp ./${helm_arch}/helm /usr/local/bin
popd
rm -rf $tdir

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
