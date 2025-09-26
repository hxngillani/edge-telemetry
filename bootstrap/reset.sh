#!/usr/bin/env bash
set -euo pipefail

echo "[WARN] ⚠️ This will perform a FULL system reset: RKE2, Docker, configs, PVCs, CNI, iptables."
read -p "Are you sure you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "[INFO] Aborted."
  exit 0
fi

echo "[INFO] 🚨 Stopping services..."
sudo systemctl stop rke2-server rke2-agent docker || true
sudo systemctl disable rke2-server rke2-agent docker || true

echo "[INFO] 🔥 Removing RKE2 files..."
sudo rm -rf /etc/rancher /var/lib/rancher /var/lib/kubelet /var/lib/etcd

echo "[INFO] 🔥 Removing Docker files..."
sudo apt purge -y docker.io || true
sudo rm -rf /var/lib/docker

echo "[INFO] 🔥 Removing Kubernetes config..."
rm -rf ~/.kube/config

echo "[INFO] 🔌 Removing CNI interfaces..."
for i in $(ip -o link show | awk -F': ' '/cali|flannel|cni/ {print $2}' | sed 's/@.*//'); do
  echo "[INFO] Deleting interface: $i"
  sudo ip link delete "$i" || true
done

echo "[INFO] 🔄 Cleaning iptables rules..."
sudo iptables -F || true
sudo iptables -t nat -F || true
sudo iptables -t mangle -F || true
sudo iptables -X || true

echo "[INFO] 🧹 Removing RKE2 binaries..."
sudo rm -f /usr/local/bin/{kubectl,ctr,crictl}

echo "[INFO] ✅ Reset complete. Run 'bash bootstrap/install.sh' to reinstall."
