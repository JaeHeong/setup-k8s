#!/bin/bash

# Step 1: Disable swap space
swapoff -a
sed -i '/swap/d' /etc/fstab

# Step 2: Install Containerd
yum install containerd -y

# Step 3: Install Kubernetes Packages (kubeadm, kubelet, kubectl)
yum install -y kubelet kubeadm kubectl

# Step 4: Enable IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Step 5: Start kubelet service
systemctl enable --now kubelet