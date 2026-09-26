<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="'playbooks'" :open="sidebarOpen" @navigate="navigateHome" @toggle-theme="toggleTheme" />

      <button class="mobile-nav-toggle" id="mobileToggle" @click="sidebarOpen = !sidebarOpen">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="3" y1="12" x2="21" y2="12"></line>
          <line x1="3" y1="6" x2="21" y2="6"></line>
          <line x1="3" y1="18" x2="21" y2="18"></line>
        </svg>
      </button>

      <main class="main-content">
        <!-- Breadcrumbs -->
        <nav class="breadcrumbs" aria-label="Breadcrumb">
          <NuxtLink to="/" class="breadcrumb-link">Home</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">Playbooks</span>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">Containers &amp; Kubernetes</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Deployment Guide :: Cloud-Native Telecom">
            <h1 class="feature-name">Container &amp; Kubernetes Deployment Guide</h1>
            <p class="feature-subtitle">Deploying official GHCR multi-stage container images, rootless Podman Telecom Pods, and Kubernetes manifests.</p>
            <div class="feature-meta-badges">
              <span class="tag tag-core">Docker</span>
              <span class="tag tag-5g">Podman Kube</span>
              <span class="tag tag-sdr">Kubernetes</span>
              <span class="tag status-ready">GHCR Published</span>
            </div>
          </header>

          <!-- Image Catalog -->
          <section class="feature-info-section">
            <h2>Official GHCR Container Catalog</h2>
            <div class="feature-long-desc">
              <p>
                TelcoChisel publishes four tiered, multi-arch container images to GitHub Container Registry (GHCR),
                optimized for continuous integration, cloud-hosted security auditing, and headless testbeds.
              </p>
            </div>

            <div class="table-container" style="overflow-x: auto; margin: 1.5rem 0;">
              <table style="width: 100%; border-collapse: collapse; font-family: var(--font-sans); font-size: 0.9rem;">
                <thead>
                  <tr style="border-bottom: 2px solid var(--bdr-mid); text-align: left;">
                    <th style="padding: 10px; color: var(--cyan-primary);">Image Repository</th>
                    <th style="padding: 10px; color: var(--cyan-primary);">Domain Scope</th>
                    <th style="padding: 10px; color: var(--cyan-primary);">Featured Tools</th>
                  </tr>
                </thead>
                <tbody>
                  <tr style="border-bottom: 1px solid var(--bdr);">
                    <td style="padding: 10px; font-family: var(--mono); color: var(--amber);">ghcr.io/telcosec-tools/telcochisel-base:latest</td>
                    <td style="padding: 10px; font-weight: 600;">Core Runtime</td>
                    <td style="padding: 10px;">telcosec CLI, Scapy, tcpdump, tshark, net-tools</td>
                  </tr>
                  <tr style="border-bottom: 1px solid var(--bdr);">
                    <td style="padding: 10px; font-family: var(--mono); color: var(--amber);">ghcr.io/telcosec-tools/telcochisel-sdr:latest</td>
                    <td style="padding: 10px; font-weight: 600;">SDR &amp; DSP</td>
                    <td style="padding: 10px;">GNU Radio 3.10, UHD, SoapySDR, HackRF, BladeRF, LimeSuite</td>
                  </tr>
                  <tr style="border-bottom: 1px solid var(--bdr);">
                    <td style="padding: 10px; font-family: var(--mono); color: var(--amber);">ghcr.io/telcosec-tools/telcochisel-core-network:latest</td>
                    <td style="padding: 10px; font-weight: 600;">Cellular Core</td>
                    <td style="padding: 10px;">Open5GS 5G SA Core, UERANSIM gNB/UE, SigPloit, Diafuzzer</td>
                  </tr>
                  <tr style="border-bottom: 1px solid var(--bdr);">
                    <td style="padding: 10px; font-family: var(--mono); color: var(--amber);">ghcr.io/telcosec-tools/telcochisel-device-tools:latest</td>
                    <td style="padding: 10px; font-weight: 600;">Hardware &amp; SIM</td>
                    <td style="padding: 10px;">Android ADB/Fastboot, QCSuper, SCAT, pySim, lpac eSIM</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>

          <!-- Deployment Steps -->
          <section class="feature-info-section">
            <h2>Deployment Walkthrough</h2>
            <ol class="numbered-guide-list">
              <li>
                <span class="guide-number">1</span>
                <div class="guide-text-block">
                  <strong>Interactive Container Execution:</strong>
                  <p>Run any containerized suite with host network and USB hardware passthrough:</p>
                  <TerminalBlock title="Terminal — Run SDR or 5G Core Container" code="# Run Core Network auditing container interactively
docker run --rm -it --net=host --privileged \
  ghcr.io/telcosec-tools/telcochisel-core-network:latest

# Run SDR container with USB device access
docker run --rm -it --net=host --privileged -v /dev/bus/usb:/dev/bus/usb \
  ghcr.io/telcosec-tools/telcochisel-sdr:latest" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Deploy Rootless Podman Telecom Pods:</strong>
                  <p>Launch multi-container pods sharing a unified localhost network namespace without root privileges:</p>
                  <TerminalBlock title="Terminal — Podman Play Kube" code="# Launch Telecom Pod (Core Network + Diagnostic Scanner)
podman play kube docker/pods/podman-telecom-pod.yaml

# Open shell in the diagnostic scanner container
podman exec -it telcochisel-telecom-pod-telecom-scanner /bin/bash

# Teardown pod when finished
podman play kube --down docker/pods/podman-telecom-pod.yaml" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Kubernetes Cluster Orchestration:</strong>
                  <p>Deploy production 5G Core Network pods into a Kubernetes cluster using the bundled deployment script:</p>
                  <TerminalBlock title="Terminal — Kubernetes Deployment" code="# Deploy 5G Core Pod into cluster
bash docker/pods/pod-deploy.sh apply-k8s docker/pods/k8s-5g-core-pod.yaml

# Verify pod status and logs
kubectl get pods -l app=telcochisel-5g-core
kubectl logs -f telcochisel-5g-core-pod -c open5gs-core" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Unified Deployment &amp; Build Manager:</strong>
                  <p>Use the all-in-one terminal wizard to launch containers, manage pods, or trigger builds:</p>
                  <TerminalBlock title="Terminal — Interactive Deployment Menu" code="./deploy_menu.sh" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Integration Details -->
          <section class="feature-info-section">
            <h2>TelcoSec Academy Integration</h2>
            <p>
              Pre-built container images can be orchestrated directly inside the 
              <a href="https://app.telcosec.net" target="_blank" rel="noopener" style="color: var(--amber); text-decoration: underline;">TelcoSec Academy Interactive Labs</a> 
              for hands-on cellular exploitation training, O-RAN auditing exercises, and red team challenge scenarios.
            </p>
          </section>
        </article>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const sidebarOpen = ref(false)

const navigateHome = () => {
  navigateTo('/')
}

const toggleTheme = () => {
  // handled globally
}

useSeoMeta({
  title: 'Container & Kubernetes Deployment Guide | TelcoChisel',
  description: 'Deploy official GHCR container images, rootless Podman Telecom Pods, and Kubernetes manifests with TelcoChisel.'
})
</script>

<style scoped>
.layout-container {
  display: flex;
  min-height: 100vh;
}
.main-content {
  flex: 1;
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}
.breadcrumbs {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  font-family: var(--mono);
  font-size: 0.85rem;
  color: var(--amber-lo);
  margin-bottom: 2rem;
}
.breadcrumb-link {
  color: var(--amber);
  text-decoration: none;
}
.breadcrumb-link:hover {
  text-decoration: underline;
}
.feature-name {
  font-size: 2.2rem;
  font-weight: 700;
  color: var(--amber-hi);
  margin-bottom: 0.5rem;
}
.feature-subtitle {
  font-size: 1.1rem;
  color: var(--tx-dim);
  margin-bottom: 1rem;
}
.feature-meta-badges {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}
.numbered-guide-list {
  list-style: none;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
.numbered-guide-list li {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}
.guide-number {
  background: var(--amber-g);
  color: var(--amber-hi);
  font-family: var(--mono);
  font-weight: 700;
  width: 2rem;
  height: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  flex-shrink: 0;
}
.guide-text-block {
  flex: 1;
}
</style>
