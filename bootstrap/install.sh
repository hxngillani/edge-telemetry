#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] 🚀 Starting installation of Edge Telemetry environment..."

# --- Update system ---
echo "[INFO] Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# --- Install dependencies ---
echo "[INFO] Installing dependencies..."
sudo apt install -y git curl wget tar lsb-release ca-certificates jq htop yamllint

# --- Install Docker ---
echo "[INFO] Installing Docker..."
if ! command -v docker &>/dev/null; then
  sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
else
  echo "[INFO] Docker already installed"
fi

# --- Install RKE2 (Kubernetes) ---
echo "[INFO] Installing RKE2 (lightweight Kubernetes)..."
if ! command -v rke2 &>/dev/null; then
  curl -sfL https://get.rke2.io | sudo sh -
fi

# --- Configure RKE2 NodePort range ---
echo "[INFO] Configuring RKE2 service-node-port-range..."
sudo mkdir -p /etc/rancher/rke2
if ! grep -q "service-node-port-range" /etc/rancher/rke2/config.yaml 2>/dev/null; then
  echo "kube-apiserver-arg: service-node-port-range=80-32767" | sudo tee -a /etc/rancher/rke2/config.yaml
  echo "[INFO] Updated RKE2 config with service-node-port-range"
fi

# Always ensure RKE2 service is running
sudo systemctl enable rke2-server.service
sudo systemctl restart rke2-server.service

# --- Configure kubectl ---
echo "[INFO] Configuring kubectl..."
sudo ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl

mkdir -p ~/.kube
if [[ -f /etc/rancher/rke2/rke2.yaml ]]; then
  sudo cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
  sudo chown $USER:$USER ~/.kube/config
else
  echo "[ERROR] kubeconfig not found at /etc/rancher/rke2/rke2.yaml"
  exit 1
fi

# --- Install Helm ---
echo "[INFO] Installing Helm..."
if ! command -v helm &>/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "[INFO] Helm already installed"
fi

# --- Verify cluster readiness ---
echo "[INFO] Waiting for Kubernetes API..."
for i in {1..30}; do
  if kubectl get nodes >/dev/null 2>&1; then
    echo "[INFO] ✅ Kubernetes API is ready!"
    kubectl get nodes -o wide
    echo "[INFO] ✅ Installation complete!"
    exit 0
  fi
  echo "[INFO] ...waiting ($i/30)"
  sleep 10
done

echo "[ERROR] ❌ Kubernetes API did not become ready after 5 minutes."
exit 1

