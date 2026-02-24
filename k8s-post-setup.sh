#!/bin/bash

set -e

echo "===== Install Calico Network Plugin ====="
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "===== Enable kubectl Autocomplete ====="
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc

echo "===== Cluster Setup Completed ====="
kubectl get nodes  echo "===== Master Node Configuration  Completed ====="
