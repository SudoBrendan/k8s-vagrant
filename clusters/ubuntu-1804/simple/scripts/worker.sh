#!/bin/bash

set -e

echo "=============================="
echo "KUBEADM JOIN WORKER"
echo "=============================="
bash /vagrant/tmp/joincluster-worker.sh
