#!/bin/bash

#https://docs.docker.com/registry/deploying/
echo "[TASK 1] Create container registry"
docker volume create registry
docker run -d -p 5000:5000 --restart=always --name registry -v registry:/var/lib/registry registry:2 >> /root/docker-registry.log 2>/dev/null

# Initialize Kubernetes
echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.42.42.100 --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log 2>/dev/null

# Copy Kube admin config
echo "[TASK 3] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Deploy flannel network
echo "[TASK 4] Deploy flannel network"
su - vagrant -c "kubectl create -f /vagrant/kube-flannel.yml"

# Generate Cluster join command
echo "[TASK 5] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh
