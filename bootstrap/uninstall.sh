#!/usr/bin/env bash
set -euo pipefail

echo "[WARN] ⚠️ This will uninstall RKE2, Docker, and configs."
read -p "Proceed? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "[INFO] Aborted."
  exit 0
fi

# --- Stop services ---
echo "[INFO] Stopping services..."
sudo systemctl stop rke2-server rke2-agent docker || true
sudo systemctl disable rke2-server rke2-agent docker || true

# --- Remove RKE2 ---
echo "[INFO] Removing RKE2 files..."
sudo rm -rf /etc/rancher /var/lib/rancher /var/lib/kubelet /var/lib/etcd

# --- Remove Docker ---
echo "[INFO] Removing Docker..."
sudo apt purge -y docker.io || true
sudo rm -rf /var/lib/docker

# --- Remove kube config ---
echo "[INFO] Removing kube config..."
rm -rf ~/.kube/config

# --- Reload systemd ---
sudo systemctl daemon-reexec

echo "[INFO] ✅ Uninstallation complete."
