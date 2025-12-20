# -*- mode: ruby -*-
# vi: set ft=ruby :

# Description : A Kubernetes development environment (K3s) with Vagrant using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/vagrant-k3s>
# Licence : GPLv3

# Vagrant version requirement
Vagrant.require_version ">= 2.0.0"

Vagrant.configure("2") do |config|
  # Box used ("rockylinux/9" is compatible with the provider "vmware_desktop")
  config.vm.box = "rockylinux/9"

  # Box must be up to date
  config.vm.box_check_update = true

  # VM Hostname
  config.vm.hostname = "k3s"

  # The plugins vagrant "vagrant-vmware-desktop" is required
  config.vagrant.plugins = "vagrant-vmware-desktop"

  # Provider configuration for "vmware_desktop"
  config.vm.provider "vmware_desktop" do |vmw|
    vmw.gui = true
    vmw.vmx["displayName"] = "k3s"
    vmw.vmx["numvcpus"] = "2"
    vmw.vmx["memsize"] = "4096"
  end

  # Forwarded port for HTTP
  config.vm.network "forwarded_port", guest: 80, host: 80, host_ip: "127.0.0.1"
  
  # Forwarded port for HTTPS
  config.vm.network "forwarded_port", guest: 443, host: 443, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM for k3s
  config.vm.synced_folder "k3s", "/k3s"

  # Disable the default share of the current code directory
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provisioning scripts
  config.vm.provision "shell", path: "provisioning.sh", env: {
    "TIMEZONE" => "Europe/Paris", # Timezone to be used by the system
    "K3S_VERSION" => "1.32.10+k3s1", # K3s version to install (v1.34.2+k3s1, 1.33.6+k3s1, 1.32.10+k3s1, ...) : https://github.com/k3s-io/k3s/releases
    "K9S_INSTALL" => "true", # Install K9s or not
    "HELM_INSTALL" => "true", # Install Helm or not
    "HELM_REPOSITORY_NAME" => "bitnami", # Helm repository name to add (if Helm is installed)
    "HELM_REPOSITORY_URL" => "https://charts.bitnami.com/bitnami", # Helm repository URL to add (if Helm is installed)
    "KUBESCORE_INSTALL" => "true", # Install kube-score or not
    "STERN_INSTALL" => "true" # Install Stern or not
  }
end