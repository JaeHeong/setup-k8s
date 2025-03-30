#!/bin/bash

# Step 1: Local Hostname Resolution
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

# Step 2: Install iproute-tc package
yum install iproute-tc -y

# Step 3: Install Containerd
yum install containerd -y

# Step 4: Modify the configuration file for containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Step 5: Start the Containerd service
systemctl enable containerd
systemctl start containerd
systemctl status containerd

# Step 6: Create network bridge settings
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Step 7: Reload and apply kernel parameters
sysctl --system

# Step 8: Disable swap space
swapoff -a
sed -i '/swap/d' /etc/fstab

# Step 9: Disable SELinux or put it into permissive mode
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Step 10: Create a YUM repository configuration file for Kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Step 11: Install Kubernetes components kubelet, kubeadm, kubectl
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Step 12: Start kubelet service automatically
systemctl enable --now kubelet