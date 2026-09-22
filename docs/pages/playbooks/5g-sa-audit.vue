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
          <span class="breadcrumb-current">5G SA Core &amp; gNB Security Audit</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Operator Playbook :: 5G Standalone Security">
            <h1 class="feature-name">5G Standalone (SA) Core &amp; gNB Security Audit</h1>
            <div class="feature-meta-badges">
              <span class="tag tag-5g">5G SA</span>
              <span class="tag tag-core">Core Network</span>
              <span class="tag status-ready">Lab Ready</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Audit Objective</h2>
            <div class="feature-long-desc">
              <p>
                This playbook provides an end-to-end workflow for auditing 5G Standalone (SA) networks using Open5GS and UERANSIM.
                Operators and penetration testers can emulate a complete 5G Service-Based Architecture (SBA), analyze NGAP signaling,
                intercept Service-Based Interface (SBI) REST communications over HTTP/2, and test NAS encryption enforcement.
              </p>
            </div>
          </section>

          <!-- Workflow Steps -->
          <section class="feature-info-section">
            <h2>Execution Steps</h2>
            <ol class="numbered-guide-list">
              <li>
                <span class="guide-number">1</span>
                <div class="guide-text-block">
                  <strong>Initialize Open5GS 5G SA Core:</strong>
                  <p>Start the containerized or native Open5GS core network daemons (AMF, SMF, UPF, NRF, UDR, AUSF):</p>
                  <TerminalBlock title="Terminal — Start 5G Core" code="sudo open5gs-install&#10;sudo telcosec 5g-sa start" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Register Test Subscriber:</strong>
                  <p>Add a simulated SIM subscription with Milenage authentication keys (K, OPc):</p>
                  <TerminalBlock title="Terminal — Provision Subscriber" code="sudo telcosec 5g-sa add-sub 999700000000001 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Simulate 5G NR gNB &amp; UE:</strong>
                  <p>Launch UERANSIM gNB and attach the virtual User Equipment to establish a PDU session:</p>
                  <TerminalBlock title="Terminal — Start gNB &amp; UE" code="nr-gnb -c /etc/telcosec/ueransim/gnb.yaml &amp;&#10;nr-ue -c /etc/telcosec/ueransim/ue.yaml" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Capture &amp; Analyze SBI Traffic:</strong>
                  <p>Inspect unencrypted or TLS-intercepted 5G SBI HTTP/2 REST APIs via Wireshark:</p>
                  <TerminalBlock title="Terminal — Wireshark SBI Analysis" code="wireshark -k -i lo -f &quot;tcp port 7777 or tcp port 8000&quot; &amp;" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Evidence Collection -->
          <section class="feature-info-section">
            <h2>Evidence &amp; Artifact Archiving</h2>
            <p>Export all PCAP captures and core network logs into a signed bundle upon completing the audit:</p>
            <TerminalBlock title="Terminal — Evidence Capture" code="telcosec bundle-evidence 5g-sa-audit" />
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
  title: '5G SA Core & gNB Security Audit Playbook | TelcoChisel',
  description: 'Operator guide and walkthrough for auditing 5G Standalone Core Networks and gNodeB RAN signaling with TelcoChisel.'
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
.feature-meta-badges {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
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
