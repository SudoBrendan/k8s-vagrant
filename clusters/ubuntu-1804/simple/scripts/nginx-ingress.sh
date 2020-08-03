#!/bin/bash

set -e

echo "=============================="
echo "NGINX INGRESS CONTROLLER"
echo "=============================="

# add repo
su vagrant -c "helm repo add nginx-stable https://helm.nginx.com/stable"
su vagrant -c "helm repo update"

# install with customizations
su vagrant -c "helm install ingress nginx-stable/nginx-ingress --namespace=ingress-nginx --create-namespace --values=/vagrant/nginx-ingress/custom-values.yaml"

