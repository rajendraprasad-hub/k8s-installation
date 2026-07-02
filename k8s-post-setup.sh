#!/bin/bash

set -e

echo "===== Install Calico Network Plugin ====="
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "===== Wait for Calico CRDs to be established ====="
kubectl wait --for=condition=Established crd/ippools.crd.projectcalico.org --timeout=120s

echo "===== Wait for default IPPool to be created ====="
until kubectl get ippool default-ipv4-ippool >/dev/null 2>&1; do
  echo "Waiting for default-ipv4-ippool to exist..."
  sleep 5
done

echo "===== Switch Calico encapsulation from IPIP to VXLAN (AWS-friendly) ====="
# AWS Security Groups block IP protocol 4 (IPIP) by default and require an explicit
# custom-protocol rule to allow it. VXLAN uses UDP/4789 instead, which is a normal
# port that's easy to allow in a Security Group. This avoids pod-to-pod / Service
# traffic silently failing between nodes on different subnets or AZs.
kubectl patch ippool default-ipv4-ippool --type merge -p '{"spec":{"ipipMode":"Never","vxlanMode":"Always"}}'

echo "===== Wait for calico-node pods to roll out with new config ====="
kubectl rollout status daemonset/calico-node -n kube-system --timeout=120s

echo "===== Verify VXLAN interface is up ====="
sleep 10
ip addr show vxlan.calico 2>/dev/null && echo "VXLAN interface confirmed." || echo "WARNING: vxlan.calico interface not found yet, check manually with: ip addr show"

echo "===== Enable kubectl Autocomplete ====="
if ! grep -q "kubectl completion bash" ~/.bashrc; then
  echo 'source <(kubectl completion bash)' >> ~/.bashrc
fi
source ~/.bashrc

echo "===== Cluster Setup Completed ====="
echo ""
echo "NOTE: Ensure your AWS Security Group allows UDP port 4789 (VXLAN) between"
echo "all cluster nodes. Protocol 4 (IPIP) is no longer required."
