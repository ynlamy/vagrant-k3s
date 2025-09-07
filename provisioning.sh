#!/bin/bash

# Description : A Kubernetes development environment (K3s) with Vagrant using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/vagrant-k3s>
# Licence : GPLv3

# Provisioning script for Rocky Linux 9 system
echo "Disbaling SELinux..."
setenforce 0
sed -i 's/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/' /etc/selinux/config

echo "Configuring Timezone..."
timedatectl set-timezone $TIMEZONE

echo "Cleaning dnf cache..."
dnf -y -q clean all &>/dev/null

echo "Updating the system..."
dnf -y -q update --exclude=kernel* &>/dev/null

echo "Installing K3s..."
K3S_VERSION=`echo "$K3S_VERSION" | sed 's/^v//'`
curl -L -s -f https://get.k3s.io | INSTALL_K3S_VERSION="v${K3S_VERSION}" K3S_KUBECONFIG_MODE="644" INSTALL_K3S_SKIP_SELINUX_RPM="true" sh - &>/dev/null
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" > /etc/profile.d/kubeconfig.sh
/usr/local/bin/k3s completion bash > /etc/bash_completion.d/k3s
/usr/local/bin/k3s kubectl completion bash > /etc/bash_completion.d/kubectl
echo "alias k=kubectl" > /etc/profile.d/kubectl-aliases.sh
echo "complete -o default -F __start_kubectl k" >> /etc/profile.d/kubectl-aliases.sh

echo "Installing K9s..."
K9S_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/derailed/k9s/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_LATEST_VERSION}/k9s_linux_amd64.rpm"
curl -L -s -O $K9S_URL &>/dev/null
dnf -y -q install k9s_linux_amd64.rpm &>/dev/null
rm -f k9s_linux_amd64.rpm

echo "Installing Helm..."
HELM_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/helm/helm/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
HELM_FILENAME="helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz"
HELM_URL="https://get.helm.sh/${HELM_FILENAME}"
curl -L -s -O $HELM_URL &>/dev/null
tar -zxf $HELM_FILENAME
mv linux-amd64/helm /usr/local/bin/helm
chown root:root /usr/local/bin/helm
/usr/local/bin/helm completion bash > /etc/bash_completion.d/helm
rm -fr linux-amd64
rm -f $HELM_FILENAME

echo -e "\nK3s is ready !"
echo "- K3s version :" `/usr/local/bin/k3s --version | grep -i "k3s version" | awk '{ print $3 }' | cut -d '"' -f2 | sed 's/^v//'`
echo "- K9s version :" `k9s version | grep -i "Version" | awk '{ print $2 }' | sed 's/^v//'`
echo "- Helm version :" `/usr/local/bin/helm version | grep -i "Version" | awk '{ print $1 }' | cut -d '"' -f2 | sed 's/^v//'`
echo -e "\nInformations :"
echo "- Guest IP address :" `ip address show eth0 | grep 'inet ' | sed -e 's/^.*inet //' -e 's/\/.*$//'`
echo "- Ingress URL for HTTP : http://127.0.0.1/"
echo "- Ingress URL for HTTPS : https://127.0.0.1/"
