# vagrant-k3s

A Kubernetes development environment with [Vagrant](https://www.vagrantup.com/) using [VMware Workstation](https://www.vmware.com/) created by Yoann LAMY under the terms of the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).

This Kubernetes environment is based on a [Rocky Linux 9](https://rockylinux.org/) distribution and contains :
* [K3s](https://k3s.io/) is a lightweight Kubernetes cluster (a single node is installed)
* [K9s](https://k9scli.io/) is a terminal based UI to interact with your Kubernetes cluster
* [Helm](https://helm.sh/) is a package manager for managing Kubernetes applications
* [kube-score](https://github.com/zegl/kube-score/) is a tool that performs static code analysis of your Kubernetes object definitions
* [Stern](https://github.com/stern/stern/) allows you to tail multiple pods on Kubernetes and multiple containers within the pod

The timezone and K3s version can be defined through the ``Vagrantfile``.

### Usage

- ``cd vagrant-k3s``
- Edit ``Vagrantfile`` to customize settings :

```
  ...
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
  ...
```

This Kubernetes environment must be started using Vagrant.

- ``vagrant up``

```
    ...
    default: Disbaling SELinux...
    default: Configuring Timezone...
    default: Cleaning dnf cache...
    default: Updating the system...
    default: Installing K3s...
    default: Installing K9s...
    default: Installing Helm...
    default: Configuring Helm repository...
    default: Installing kube-score...
    default: Installing Stern...
    default:
    default: K3s is ready !
    default: - K3s version : 1.32.10+k3s1
    default: - K9s version : 0.50.16
    default: - Helm version : 4.0.4
    default: - kube-score version : 1.20.0
    default: - Stern version : 1.33.1
    default:
    default: Informations :
    default: - Guest IP address : xxx.xxx.xxx.xxx
    default: - Ingress URL for HTTP : http://127.0.0.1/
    default: - Ingress URL for HTTPS : https://127.0.0.1/
```

And it must be destroy using Vagrant.

- ``vagrant destroy``

```
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
    ...
```