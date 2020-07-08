#!/bin/bash

echo "=============================="
echo "HOSTS FILE"
echo "=============================="
cat >>/etc/hosts<<EOF
10.0.1.10 ${PREFIX}-master0.${DOMAIN} ${PREFIX}-master0
10.0.1.20 ${PREFIX}-worker0.${DOMAIN} ${PREFIX}-worker0
10.0.1.21 ${PREFIX}-worker1.${DOMAIN} ${PREFIX}-worker1
10.0.1.22 ${PREFIX}-worker2.${DOMAIN} ${PREFIX}-worker2
10.0.1.23 ${PREFIX}-worker3.${DOMAIN} ${PREFIX}-worker3
10.0.1.24 ${PREFIX}-worker4.${DOMAIN} ${PREFIX}-worker4
EOF

echo "[TASK] Enable ssh password authentication"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd


echo "[TASK] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root


echo "[TASK] Set bash preferences"
apt-get install bash-completion
echo "export TERM=xterm" >> /etc/bashrc
