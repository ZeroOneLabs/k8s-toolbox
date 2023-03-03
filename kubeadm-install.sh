#!/usr/bin/env bash

# Housekeeping
if [[ $(whoami) != "root" ]];then
    echo "This script must be executed as root"
    exit 1
fi


# Define variables
K8S_PORT=6443
POD_CIDR="192.168.0.0/16"
KUBEADM_VERSION="1.24.0"

# Definal localization
lang_port_available="Port ${K8S_PORT} is available on localhost"
lang_port_unavailable="Error: Port ${K8S_PORT} is UNAVAILABLE on localhost"


# Define functions
func logger () {
    local arg log_level log_message
    while getopts 'l:m:' arg
    do
        case ${arg} in
            l) log_level=${OPTARG};;
            m) log_message=${OPTARG};;
            *) return 1 # bad option
        esac
    done    date_iso_stamp="$(date +"%Y-%m-%dT%H:%M:%S%z")"
    echo "${date_iso_stamp} - ${log_level}: ${log_message}"
}

## Requirements

# Make sure we're on a Debian or Red Hat distro

# 2+ GB of RAM available to host

# 2 CPUs or more

# Check certain ports are open
if $(nc 127.0.0.1 ${K8S_PORT});then 
    logger -l "INFO" -m "${lang_port_available}"
else
    logger -l "INFO" -m  "${lang_port_unavailable}"
fi


# Install containerd
## Uninstall old versions
apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Verify that the Docker Engine installation is successful by running
sudo service docker start
sudo docker run hello-world


# - - - 

# Install kubeadm
##  Debian install commands
apt-get install -y apt-transport-https ca-certificates curl

curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update && apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


# Configure 
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter




# control plane commands
kubeadm init --pod-network-cidr ${POD_CIDR} --kubernetes-version ${KUBEADM_VERSION}

## prints join command for worker nodes
kubeadm token create --print-join-command