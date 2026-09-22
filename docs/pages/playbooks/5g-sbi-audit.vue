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
          <span class="breadcrumb-current">5G SBI REST API &amp; SEPP Security Audit</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Operator Playbook :: 5G SBA & Core APIs">
            <h1 class="feature-name">5G Core Service Based Interface (SBI) &amp; SEPP Security Audit</h1>
            <div class="feature-meta-badges">
              <span class="tag tag-5g">5G SBI</span>
              <span class="tag tag-core">REST / HTTP/2</span>
              <span class="tag status-ready">3GPP Rel-17</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Audit Objective</h2>
            <div class="feature-long-desc">
              <p>
                In 5G Service-Based Architecture (SBA), Network Functions (NFs) communicate over HTTP/2 using JSON REST APIs.
                This playbook demonstrates how to validate 3GPP OpenAPI 3.0 schema compliance, audit OAuth2 token authorization,
                fuzz Service-Based Interfaces (NRF, AMF, UDM, AUSF), and analyze inter-PLMN roaming security at the Security Edge Protection Proxy (SEPP / N32).
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
                  <strong>Check 5G SBI &amp; Schema Status:</strong>
                  <p>Confirm that 3GPP Release 16/17/18 OpenAPI definitions are loaded into the local system:</p>
                  <TerminalBlock title="Terminal — Check SBI Specs" code="telcosec sbi status" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Validate OpenAPI 3.0 Contract Compliance:</strong>
                  <p>Verify that target 5G Core REST endpoints strictly conform to standard 3GPP JSON specifications:</p>
                  <TerminalBlock title="Terminal — Validate SBI Contract" code="telcosec sbi validate http://127.0.0.1:7777 nrf" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Launch Mutational REST API Fuzzer:</strong>
                  <p>Send mutated JSON payloads, header injections, and token bypass sequences against the target NF:</p>
                  <TerminalBlock title="Terminal — Fuzz SBI Endpoints" code="telcosec sbi fuzz http://127.0.0.1:7777 amf" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Intercept &amp; Modify SBI Traffic with mitmproxy:</strong>
                  <p>Run interactive HTTP/2 interception proxy to tamper with live NF discovery responses:</p>
                  <TerminalBlock title="Terminal — mitmproxy Interception" code="mitmproxy --listen-port 8080 --mode reverse:http://127.0.0.1:7777" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Evidence Collection -->
          <section class="feature-info-section">
            <h2>Evidence &amp; Artifact Archiving</h2>
            <p>Export all HTTP/2 transaction PCAPs and fuzzer anomaly reports into a signed archive:</p>
            <TerminalBlock title="Terminal — Bundle Evidence" code="telcosec bundle-evidence 5g-sbi-audit" />
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
  title: '5G SBI REST API & SEPP Security Audit Playbook | TelcoChisel',
  description: 'Operator guide for auditing 5G Service Based Architecture (SBA) APIs, OAuth2 tokens, and SEPP roaming interfaces with TelcoChisel.'
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
