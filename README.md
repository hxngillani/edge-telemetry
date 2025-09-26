# Edge Telemetry 🚀

A minimal Kubernetes-based telemetry platform for edge environments.
It provides a reproducible stack with:

* **Mosquitto** → MQTT broker for telemetry publishing
* **Node-RED** → flow-based programming and data routing
* **InfluxDB** → time-series database for telemetry storage
* **Grafana** → visualization dashboards

Built on top of:

* **RKE2** → lightweight Kubernetes
* **Docker** → container runtime
* **Helm** → package manager for Kubernetes
* **Makefile automation** for lifecycle tasks

---

## 📑 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [Installation](#-installation)
3. [Deploy Telemetry Stack](#-deploy-telemetry-stack)
4. [Access Services](#-access-services)
5. [Cluster Lifecycle](#-cluster-lifecycle)
6. [Cleanup](#-cleanup)
7. [Notes](#-notes)

---

## 📋 Prerequisites

* Fresh **Ubuntu 22.04+** machine (VM, edge PC, or server)
* `sudo` privileges
* Minimum resources: **2 CPU, 4 GB RAM, 20 GB disk**
* Internet connection

---

## 🚀 Installation

Clone the repo and run installer:

```bash
git clone git@github.com:yourname/edge-telemetry.git
cd edge-telemetry
make install
```

This will:

* Install **Docker, RKE2, kubectl, helm, yamllint**
* Configure Kubernetes (`~/.kube/config`)
* Verify cluster readiness

Check cluster:

```bash
kubectl get nodes -o wide
```

---

## 📡 Deploy Telemetry Stack

```bash
make apply
```

This will deploy:

* Namespace `telemetry`
* Mosquitto, Node-RED, InfluxDB, Grafana

Check resources:

```bash
make status
```

---

## 🌐 Access Services

Find your node IP and exposed NodePorts:

```bash
make ip
```

Example:

* Grafana → `http://192.168.3.199:3000`
* InfluxDB → `http://192.168.3.199:8086`
* Node-RED → `http://192.168.3.199:1880`
* Mosquitto → `tcp://192.168.3.199:1883`

Default NodePorts are fixed:

* Grafana → 3000
* InfluxDB → 8086
* Node-RED → 1880
* Mosquitto → 1883

---

## 🔄 Cluster Lifecycle

### Stop cluster before shutting down PC:

```bash
make stop
```

### Restart cluster after boot:

```bash
make start
```

### Check health:

```bash
make status
```

---

## 🧹 Cleanup

* Remove only telemetry stack:

  ```bash
  make delete
  ```

* Uninstall RKE2 + Docker:

  ```bash
  make uninstall
  ```

* Full system reset (wipe everything):

  ```bash
  make reset
  ```

---

## 📖 Notes

* Use `make lint` to validate YAML manifests.
* NodePorts are fixed for easier access.
* RKE2 runs as a **single-node cluster** by default (server only).

---
