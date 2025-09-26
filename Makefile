.PHONY: install uninstall reset lint apply delete status ip stop start

# --- Installation targets ---
install:
	@echo "[INFO] 🚀 Installing full Edge Telemetry stack..."
	bash bootstrap/install.sh

uninstall:
	@echo "[INFO] 🧹 Uninstalling Edge Telemetry stack..."
	bash bootstrap/uninstall.sh

reset:
	@echo "[WARN] ⚠️ Performing FULL system reset (RKE2, Docker, configs)..."
	bash bootstrap/reset.sh

# --- Validation ---
lint:
	@echo "[INFO] 🔎 Running yamllint on Kubernetes manifests..."
	yamllint deployments/

# --- Workload deployment ---
apply:
	@echo "[INFO] 📦 Creating namespace..."
	kubectl apply -f deployments/namespace.yaml
	@echo "[INFO] 📦 Applying telemetry stack..."
	kubectl apply -f deployments/ --recursive


delete:
	@echo "[INFO] 🗑️ Deleting telemetry stack..."
	kubectl delete -f deployments/ --ignore-not-found=true || true

# --- Cluster status ---
status:
	@echo "[INFO] 📡 Cluster status:"
	kubectl get nodes -o wide
	kubectl get pods -n telemetry -o wide || true
	kubectl get svc -n telemetry -o wide || true

# --- IP & Service access ---
ip:
	@echo "Node IP: $$(hostname -I | awk '{print $$1}')"
	@echo "Grafana:  http://$$(hostname -I | awk '{print $$1}'):3000"
	@echo "InfluxDB: http://$$(hostname -I | awk '{print $$1}'):8086"
	@echo "Node-RED: http://$$(hostname -I | awk '{print $$1}'):1880"
	@echo "Mosquitto (MQTT): tcp://$$(hostname -I | awk '{print $$1}'):1883"

# --- Lifecycle management ---
stop:
	@echo "[INFO] ⏹️ Stopping RKE2 and Docker..."
	sudo systemctl stop rke2-server rke2-agent docker || true
	sudo rm -rf /var/lib/rancher/rke2/server/db/etcd


start:
	@echo "[INFO] ▶️ Starting Docker and RKE2..."
	sudo systemctl start docker || true
	sudo systemctl start rke2-server
	@echo "[INFO] ⏳ Waiting for Kubernetes API to become ready..."
	@for i in 1 2 3 4 5; do \
	  if kubectl get nodes >/dev/null 2>&1; then \
	    echo "[INFO] ✅ Cluster is ready!"; \
	    kubectl get nodes -o wide; \
	    exit 0; \
	  fi; \
	  echo "[INFO] ...waiting ($$i/5)"; \
	  sleep 10; \
	done; \
	echo "[ERROR] ❌ Cluster did not become ready in time" && exit 1
