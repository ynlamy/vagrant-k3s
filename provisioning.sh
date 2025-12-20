#!/bin/bash

# Description : A Kubernetes development environment (K3s) with Vagrant using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/vagrant-k3s>
# Licence : GPLv3

# Provisioning script for Rocky Linux 9 system
if [ -z "$K3S_VERSION" ]; then
  echo "The K3s version to install has not been defined..."
  exit 1
fi

echo "Disbaling SELinux..."
setenforce 0
sed -i 's/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/' /etc/selinux/config

if [ -n "$TIMEZONE" ]; then
  echo "Configuring Timezone..."
  timedatectl set-timezone $TIMEZONE
fi

echo "Cleaning dnf cache..."
dnf -y -q clean all &>/dev/null

echo "Updating the system..."
dnf -y -q update --exclude=kernel* &>/dev/null

echo "Installing K3s..."
K3S_VERSION=`echo "$K3S_VERSION" | sed 's/^v//'`
curl -L -s -f https://get.k3s.io | INSTALL_K3S_VERSION="v${K3S_VERSION}" INSTALL_K3S_SKIP_SELINUX_RPM="true" sh - &>/dev/null
echo "export KUBECONFIG=~/.kube/config" > /etc/profile.d/kubeconfig.sh
mkdir /root/.kube/
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
echo 'PATH=$PATH:/usr/local/bin/' >> /root/.bash_profile
mkdir /home/vagrant/.kube/
chown vagrant:vagrant /home/vagrant/.kube/
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
/usr/local/bin/k3s completion bash > /etc/bash_completion.d/k3s
/usr/local/bin/k3s kubectl completion bash > /etc/bash_completion.d/kubectl
echo "alias k=kubectl" > /etc/profile.d/kubectl-aliases.sh
echo "complete -o default -F __start_kubectl k" >> /etc/profile.d/kubectl-aliases.sh

if [ "$K9S_INSTALL" = true ]; then
  echo "Installing K9s..."
  K9S_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/derailed/k9s/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
  K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_LATEST_VERSION}/k9s_linux_amd64.rpm"
  curl -L -s -O $K9S_URL &>/dev/null
  dnf -y -q install k9s_linux_amd64.rpm &>/dev/null
  rm -f k9s_linux_amd64.rpm
fi

if [ "$HELM_INSTALL" = true ]; then
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

  if [ -n "$HELM_REPOSITORY_NAME" ] || [-n "$HELM_REPOSITORY_URL" ]; then
    echo "Configuring Helm repository..."
    /usr/local/bin/helm repo add $HELM_REPOSITORY_NAME $HELM_REPOSITORY_URL &>/dev/null
    mkdir /home/vagrant/.config/
    cp -R /root/.config/helm/ /home/vagrant/.config/
    chown -R vagrant:vagrant /home/vagrant/.config/
    mkdir /home/vagrant/.cache/
    cp -R /root/.cache/helm/ /home/vagrant/.cache/
    chown -R vagrant:vagrant /home/vagrant/.cache/
  fi
fi

if [ "$KUBESCORE_INSTALL" = true ]; then
  echo "Installing kube-score..."
  KUBESCORE_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/zegl/kube-score/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
  KUBESCORE_FILENAME="kube-score_${KUBESCORE_LATEST_VERSION//v/}_linux_amd64.tar.gz"
  KUBESCORE_URL="https://github.com/zegl/kube-score/releases/download/${KUBESCORE_LATEST_VERSION}/${KUBESCORE_FILENAME}"
  curl -L -s -O $KUBESCORE_URL &>/dev/null
  tar -zxf $KUBESCORE_FILENAME
  mv kube-score /usr/local/bin/
  rm -f LICENSE
  rm -f $KUBESCORE_FILENAME
fi

if [ "$STERN_INSTALL" = true ]; then
  echo "Installing Stern..."
  STERN_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/stern/stern/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
  STERN_FILENAME="stern_${STERN_LATEST_VERSION//v/}_linux_amd64.tar.gz"
  STERN_URL="https://github.com/stern/stern/releases/download/${STERN_LATEST_VERSION}/${STERN_FILENAME}"
  curl -L -s -O $STERN_URL &>/dev/null
  tar -zxf $STERN_FILENAME
  mv stern /usr/local/bin/
  rm -f LICENSE
  rm -f $STERN_FILENAME
fi

echo -e "\nK3s is ready !"
echo "- K3s version :" `/usr/local/bin/k3s --version | grep -i "k3s version" | awk '{ print $3 }' | cut -d '"' -f2 | sed 's/^v//'`
if [ "$K9S_INSTALL" = true ]; then
  echo "- K9s version :" `k9s version | grep -i "Version" | awk '{ print $2 }' | sed 's/^v//'`
fi
if [ "$HELM_INSTALL" = true ]; then
  echo "- Helm version :" `/usr/local/bin/helm version | grep -i "Version" | awk '{ print $1 }' | cut -d '"' -f2 | sed 's/^v//'`
fi
if [ "$KUBESCORE_INSTALL" = true ]; then
  echo "- kube-score version :" `/usr/local/bin/kube-score version | grep -i "version" | awk '{ print $3 }' | sed 's/.$//'`
fi
if [ "$STERN_INSTALL" = true ]; then
  echo "- Stern version :" `/usr/local/bin/stern --version | grep -i "version" | awk '{ print $2 }'`
fi
echo -e "\nInformations :"
echo "- Guest IP address :" `ip address show eth0 | grep 'inet ' | sed -e 's/^.*inet //' -e 's/\/.*$//'`
echo "- Ingress URL for HTTP : http://127.0.0.1/"
echo "- Ingress URL for HTTPS : https://127.0.0.1/"
