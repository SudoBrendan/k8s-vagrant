#!/bin/bash
# info: https://metallb.universe.tf/installation/

set -e

echo "=============================="
echo "METALLB"
echo "=============================="

# fix kube-proxy config
su vagrant -c 'kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system'

# apply MetalLB manifests
pushd /vagrant/metallb
    wget -q -O namespace.yaml https://raw.githubusercontent.com/metallb/metallb/main/manifests/namespace.yaml?ref=v0.9.3
    wget -q -O metallb.yaml https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml?ref=v0.9.3
popd
su vagrant -c 'kubectl apply -k /vagrant/metallb/'

