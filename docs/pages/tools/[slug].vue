<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="'tools'" :open="sidebarOpen" @navigate="navigateHome" @toggle-theme="toggleTheme" />

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
          <NuxtLink to="/#tools" class="breadcrumb-link">Tools Directory</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">{{ tool.name }}</span>
        </nav>

        <article v-if="tool" class="tool-details-page">
          <!-- Page Header -->
          <header class="section-header" :data-label="'// Tool Documentation :: ' + tool.name">
            <h1 class="tool-name">{{ tool.name }}</h1>
            <div class="tool-meta-badges">
              <span class="tag" :class="tagClass(tool.category)">{{ tagLabel(tool.category) }}</span>
              <span class="tag" :class="tool.status === 'setup' ? 'status-setup' : 'status-ready'">
                {{ tool.status === 'setup' ? 'Setup Required' : 'Ready to Run' }}
              </span>
              <span class="tool-location-badge">Location: <code>{{ tool.path }}</code></span>
            </div>
          </header>

          <!-- CLI Command Block -->
          <section class="tool-cli-section">
            <h2>Command Line Execution</h2>
            <p>Run this command in the TelcoChisel terminal to launch or execute the tool:</p>
            <TerminalBlock :title="tool.name + ' Command'" :code="tool.cmd" />
          </section>

          <!-- Technical Overview -->
          <section class="tool-info-section">
            <h2>Detailed Technical Overview</h2>
            <div class="tool-long-desc">
              <p>{{ tool.overview }}</p>
            </div>
          </section>

          <!-- Configuration & Usage -->
          <section class="tool-info-section">
            <h2>Configuration &amp; Usage Guide</h2>
            <p>To initialize and configure <strong>{{ tool.name }}</strong> for telecom security audits, follow these steps:</p>
            <ol class="numbered-guide-list">
              <li v-for="(step, idx) in tool.config" :key="idx">
                <span class="guide-number">{{ idx + 1 }}</span>
                <span class="guide-text">{{ step }}</span>
              </li>
            </ol>
          </section>

          <!-- Troubleshooting -->
          <section class="tool-info-section" v-if="tool.troubleshooting">
            <h2>Troubleshooting &amp; Security Audits</h2>
            <AppCallout type="warning" :title="tool.name + ' Audit Warning'">
              {{ tool.troubleshooting }}
            </AppCallout>
          </section>

          <!-- FAQ Accordion for AEO -->
          <section class="tool-info-section tool-faq-section" v-if="tool.faq && tool.faq.length">
            <h2>Frequently Asked Questions</h2>
            <div class="faq-list">
              <details v-for="(faq, idx) in tool.faq" :key="idx" class="faq-item">
                <summary class="faq-question">{{ faq.q }}</summary>
                <div class="faq-answer">
                  <p>{{ faq.a }}</p>
                </div>
              </details>
            </div>
          </section>

          <!-- Footer CTA -->
          <div class="back-footer-cta">
            <NuxtLink to="/#tools" class="btn-back-link">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
              </svg>
              Back to Tools Directory
            </NuxtLink>
          </div>
        </article>

        <div v-else class="error-container">
          <h2>Tool Not Found</h2>
          <p>The requested cellular pentesting instrument could not be identified.</p>
          <NuxtLink to="/#tools" class="btn-back-link">Return to Tools Directory</NuxtLink>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { toolsCatalog } from '~/data/tools.js'
import { getToolMetadata } from '~/utils/toolMetadata.js'

const route = useRoute()
const sidebarOpen = ref(false)

// Lookup tool
const rawTool = toolsCatalog.find(t => t.slug === route.params.slug)
const tool = rawTool ? getToolMetadata(rawTool) : null

if (!tool) {
  throw createError({ statusCode: 404, statusMessage: 'Tool not found' })
}

// SEO Head setup via generic composable
useToolSchema({
  name: tool.name,
  description: `Learn how to run and configure ${tool.name} inside TelcoChisel by TelcoSec for advanced Telecom Security and ${tool.keywords[0] || 'cellular security auditing'}. CLI commands, setup steps, and technical FAQs.`,
  category: "SecurityApplication",
  slug: tool.slug,
  isFree: true,
  faq: tool.faq,
  keywords: [...(tool.keywords || []), tool.name, 'TelcoSec', 'TelcoChisel', 'Telecom Security', 'cellular pentesting']
})

// Navigation home helper
function navigateHome(section) {
  sidebarOpen.value = false
  navigateTo(`/#${section}`)
}

// Theme management
function toggleTheme() {
  const isLight = document.body.classList.toggle('light-theme')
  localStorage.setItem('theme', isLight ? 'light' : 'dark')
}

onMounted(() => {
  if (localStorage.getItem('theme') === 'light') document.body.classList.add('light-theme')
})

// Tag helper functions
function tagClass(cat) {
  return {
    sdr:     'tag-sdr',
    gsm:     'tag-gsm',
    lte:     'tag-lte',
    '5g':    'tag-5g',
    ue:      'tag-ue',
    sim:     'tag-sim',
    ran:     'tag-ran',
    device:  'tag-device',
    network: 'tag-network',
    voip:    'tag-voip',
    sys:     'tag-sys'
  }[cat] || ''
}

function tagLabel(cat) {
  return {
    sdr:     'SDR',
    gsm:     'GSM / 2G',
    lte:     'LTE / 4G',
    '5g':    '5G NR',
    ue:      'UE & Baseband',
    sim:     'SIM / Smartcard',
    ran:     'RAN & Signaling',
    device:  'Device Tools',
    network: 'Network',
    voip:    'VoIP',
    sys:     'System'
  }[cat] || cat
}
</script>

<style scoped>
/* Breadcrumbs Styling */
.breadcrumbs {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 24px;
  font-family: var(--mono);
  font-size: 0.75rem;
}

.breadcrumb-link {
  color: var(--tx-dim);
  text-decoration: none;
  transition: color var(--t);
}

.breadcrumb-link:hover {
  color: var(--amber);
}

.breadcrumb-separator {
  color: var(--tx-faint);
  user-select: none;
}

.breadcrumb-current {
  color: var(--amber);
  font-weight: 500;
}

/* Badges wrapper */
.tool-meta-badges {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-top: 10px;
}

.tool-location-badge {
  font-family: var(--mono);
  font-size: 0.75rem;
  color: var(--tx-dim);
}

.tool-location-badge code {
  color: var(--tx);
  background: var(--bg-inset);
  padding: 2px 6px;
  border-radius: 2px;
  border: 1px solid var(--bdr);
}

/* Section styling */
.tool-cli-section {
  margin: 32px 0;
}

.tool-info-section {
  margin: 40px 0;
}

.tool-long-desc p {
  font-size: 0.95rem;
  line-height: 1.85;
  color: var(--tx);
}

/* Numbered Guide List */
.numbered-guide-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin: 20px 0;
}

.numbered-guide-list li {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.guide-number {
  width: 28px;
  height: 28px;
  background: var(--bg-inset);
  border: 1px solid var(--bdr-mid);
  color: var(--amber);
  font-family: var(--mono);
  font-size: 0.82rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 2px;
  flex-shrink: 0;
}

.guide-text {
  font-size: 0.9rem;
  line-height: 1.7;
  color: var(--tx-dim);
  padding-top: 2px;
}

/* Back button footer CTA */
.back-footer-cta {
  margin-top: 60px;
  padding-top: 30px;
  border-top: 1px solid var(--bdr);
}

.btn-back-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-family: var(--disp);
  font-size: 0.95rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--amber);
  border: 1px solid var(--amber-lo);
  background: var(--amber-g2);
  padding: 8px 16px;
  border-radius: 2px;
  transition: all var(--t);
}

.btn-back-link:hover {
  color: var(--tx);
  background: var(--amber-g);
  border-color: var(--amber);
  transform: translateX(-3px);
  box-shadow: 0 4px 20px var(--amber-g2);
}

.btn-back-link svg {
  transition: transform var(--t);
}

.btn-back-link:hover svg {
  transform: translateX(-3px);
}

.error-container {
  text-align: center;
  padding: 80px 20px;
}

.error-container h2 {
  margin-bottom: 12px;
  border: none;
}
</style>
