#!/usr/bin/env bash
# =============================================================================
# docker/pods/pod-deploy.sh — Telecom POD Deployment & Management Helper
#
# Provides a unified CLI to deploy, inspect, and tear down TelcoChisel
# multi-container pods on Podman (rootless workstation) or Kubernetes (cluster).
#
# Usage:
#   bash docker/pods/pod-deploy.sh start-podman [manifest.yaml]
#   bash docker/pods/pod-deploy.sh stop-podman  [manifest.yaml]
#   bash docker/pods/pod-deploy.sh apply-k8s    [manifest.yaml]
#   bash docker/pods/pod-deploy.sh delete-k8s   [manifest.yaml]
#   bash docker/pods/pod-deploy.sh status
#   bash docker/pods/pod-deploy.sh exec <pod-or-container> [command]
#   bash docker/pods/pod-deploy.sh logs <container>
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PODMAN_MANIFEST="${SCRIPT_DIR}/podman-telecom-pod.yaml"
DEFAULT_K8S_MANIFEST="${SCRIPT_DIR}/k8s-5g-core-pod.yaml"

usage() {
  cat << 'EOF'
TelcoChisel Telecom POD Deployment Helper

Usage:
  pod-deploy.sh start-podman [manifest]   Start pod via rootless Podman (default: podman-telecom-pod.yaml)
  pod-deploy.sh stop-podman  [manifest]   Stop pod via Podman
  pod-deploy.sh apply-k8s    [manifest]   Deploy manifest to Kubernetes (default: k8s-5g-core-pod.yaml)
  pod-deploy.sh delete-k8s   [manifest]   Delete manifest from Kubernetes
  pod-deploy.sh status                    Check status of Podman pods and Kubernetes pods
  pod-deploy.sh exec <target> [cmd...]    Shell into target container (default: /bin/bash)
  pod-deploy.sh logs <target>             Stream logs from target container
  pod-deploy.sh list-manifests            List available POD manifests

Available manifests:
  - k8s-5g-core-pod.yaml        (5G Core + UERANSIM RAN simulation)
  - k8s-sdr-rf-pod.yaml         (SDR over-the-air capture & real-time I/Q)
  - k8s-device-audit-pod.yaml   (Modem diagnostic & baseband firmware audit)
  - k8s-telecom-suite-pod.yaml  (Full red team telecom assessment suite)
  - podman-telecom-pod.yaml     (Turnkey Podman rootless telecom pod)
EOF
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  start-podman)
    manifest="${1:-$DEFAULT_PODMAN_MANIFEST}"
    if ! command -v podman &>/dev/null; then
      echo "ERROR: 'podman' command not found. Please install Podman." >&2
      exit 1
    fi
    echo "=== Starting Podman Telecom POD from ${manifest} ==="
    podman play kube "$manifest"
    echo "POD deployed successfully! Inspect status with: $0 status"
    ;;

  stop-podman)
    manifest="${1:-$DEFAULT_PODMAN_MANIFEST}"
    if ! command -v podman &>/dev/null; then
      echo "ERROR: 'podman' command not found." >&2
      exit 1
    fi
    echo "=== Stopping Podman Telecom POD from ${manifest} ==="
    podman play kube --down "$manifest"
    ;;

  apply-k8s)
    manifest="${1:-$DEFAULT_K8S_MANIFEST}"
    if ! command -v kubectl &>/dev/null; then
      echo "ERROR: 'kubectl' command not found. Please install kubectl." >&2
      exit 1
    fi
    echo "=== Deploying Kubernetes Pod manifest: ${manifest} ==="
    kubectl apply -f "$manifest"
    ;;

  delete-k8s)
    manifest="${1:-$DEFAULT_K8S_MANIFEST}"
    if ! command -v kubectl &>/dev/null; then
      echo "ERROR: 'kubectl' command not found." >&2
      exit 1
    fi
    echo "=== Deleting Kubernetes Pod manifest: ${manifest} ==="
    kubectl delete -f "$manifest" --ignore-not-found=true
    ;;

  status)
    echo "================================================================"
    echo "  TelcoChisel Telecom POD Status"
    echo "================================================================"
    if command -v podman &>/dev/null; then
      echo "--- [Podman Pods] ---"
      podman pod ps 2>/dev/null || echo "No active Podman pods or daemon not accessible."
      echo ""
      echo "--- [Podman Containers] ---"
      podman ps --filter "label=net.telcosec.product=telcochisel" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true
    fi
    echo ""
    if command -v kubectl &>/dev/null; then
      echo "--- [Kubernetes Pods] ---"
      kubectl get pods -o wide 2>/dev/null || echo "Kubernetes cluster not accessible or no pods."
    fi
    echo "================================================================"
    ;;

  exec)
    target="${1:-}"
    if [ -z "$target" ]; then
      echo "ERROR: Missing target container or pod name. Usage: $0 exec <name> [cmd]" >&2
      exit 1
    fi
    shift || true
    run_cmd="${*:-/bin/bash}"
    if command -v podman &>/dev/null && podman ps -q --filter "name=${target}" | grep -q .; then
      exec podman exec -it "$target" $run_cmd
    elif command -v kubectl &>/dev/null; then
      exec kubectl exec -it "$target" -- $run_cmd
    else
      echo "ERROR: Target '${target}' not found in active Podman or Kubernetes containers." >&2
      exit 1
    fi
    ;;

  logs)
    target="${1:-}"
    if [ -z "$target" ]; then
      echo "ERROR: Missing target container or pod name. Usage: $0 logs <name>" >&2
      exit 1
    fi
    if command -v podman &>/dev/null && podman ps -a -q --filter "name=${target}" | grep -q .; then
      exec podman logs -f "$target"
    elif command -v kubectl &>/dev/null; then
      exec kubectl logs -f "$target"
    else
      echo "ERROR: Target '${target}' not found." >&2
      exit 1
    fi
    ;;

  list-manifests)
    echo "Available Telecom POD manifests in ${SCRIPT_DIR}:"
    ls -lh "${SCRIPT_DIR}"/*.yaml
    ;;

  help|-h|--help)
    usage
    ;;

  *)
    echo "Unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac
