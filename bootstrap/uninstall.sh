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
sudo systemctl stop rke2-server rke2-agent docker containerd || true
sudo systemctl disable rke2-server rke2-agent docker containerd || true
sudo pkill -9 -f "containerd-shim" || true
sudo pkill -9 -f "containerd" || true

# --- Clean up mounts ---
echo "[INFO] Unmounting kubelet and containerd mounts..."
for m in $(mount | grep -E 'kubelet|containerd' | awk '{print $3}'); do
  echo "  - Unmounting $m"
  sudo umount -l "$m" || true
done

# --- Remove RKE2 ---
echo "[INFO] Removing RKE2 files..."
sudo rm -rf /etc/rancher \
            /var/lib/rancher \
            /var/lib/kubelet \
            /var/lib/etcd \
            /run/k3s

# --- Remove Docker ---
echo "[INFO] Removing Docker..."
sudo apt purge -y docker.io || true
sudo rm -rf /var/lib/docker

# --- Remove kube config ---
echo "[INFO] Removing kube config..."
rm -rf ~/.kube/config

# --- Remove leftover CNI interfaces ---
echo "[INFO] Removing leftover CNI interfaces..."
# Delete flannel
sudo ip link delete flannel.1 2>/dev/null || true
# Delete all calico veths
for i in $(ip -o link show | awk -F': ' '{print $2}' | grep '^cali'); do
  echo "  - Deleting $i"
  sudo ip link delete "$i" 2>/dev/null || true
done

# --- Clean up network namespaces ---
echo "[INFO] Cleaning up dangling network namespaces..."
for ns in $(ip netns list | awk '{print $1}'); do
  echo "  - Deleting netns $ns"
  sudo ip netns delete "$ns" || true
done

# --- Reload systemd ---
echo "[INFO] Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "[INFO] ✅ Uninstallation complete."
