<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="'drivers'" :open="sidebarOpen" @navigate="navigateHome" @toggle-theme="toggleTheme" />

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
          <NuxtLink to="/#drivers" class="breadcrumb-link">Drivers &amp; Hardware</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">{{ driver.name }}</span>
        </nav>

        <article v-if="driver" class="driver-details-page">
          <!-- Page Header -->
          <header class="section-header" :data-label="'// Hardware Interface :: ' + driver.name">
            <h1 class="driver-name">{{ driver.name }}</h1>
            <div class="driver-meta-badges">
              <span class="tag tag-sdr">{{ tagLabel(driver.category) }}</span>
              <span class="tag status-ready">Driver Pre-compiled</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="driver-info-section">
            <h2>Hardware Overview &amp; Capabilities</h2>
            <div class="driver-long-desc">
              <p>{{ metadata.overview }}</p>
            </div>
          </section>

          <!-- udev Rules configuration -->
          <section class="driver-info-section" v-if="driver.udev">
            <h2>udev Rule (Non-Root USB Permissions)</h2>
            <p>TelcoChisel automatically deploys this configuration in <code>/etc/udev/rules.d/50-telcosec-hw.rules</code> to permit hardware access without root privileges:</p>
            <TerminalBlock title="udev Configuration" :code="driver.udev" />
          </section>

          <!-- CLI Diagnostic Command -->
          <section class="driver-info-section">
            <h2>Hardware Verification &amp; Diagnostics</h2>
            <p>Run the following command to test communication and print hardware parameters:</p>
            <TerminalBlock :title="driver.name + ' Diagnostic'" :code="driver.cmd" />
          </section>

          <!-- Configuration steps -->
          <section class="driver-info-section">
            <h2>Step-by-Step Configuration Guide</h2>
            <p>Follow these instructions to connect and register the hardware interface:</p>
            <ol class="numbered-guide-list">
              <li v-for="(step, idx) in metadata.config" :key="idx">
                <span class="guide-number">{{ idx + 1 }}</span>
                <span class="guide-text">{{ step }}</span>
              </li>
            </ol>
          </section>

          <!-- Troubleshooting -->
          <section class="driver-info-section" v-if="metadata.troubleshooting">
            <h2>Common Pitfalls &amp; Jitter Mitigation</h2>
            <AppCallout type="warning" title="SDR Hardware Constraints">
              {{ metadata.troubleshooting }}
            </AppCallout>
          </section>

          <!-- FAQs for AEO -->
          <section class="driver-info-section driver-faq-section" v-if="metadata.faq && metadata.faq.length">
            <h2>Hardware Frequently Asked Questions</h2>
            <div class="faq-list">
              <details v-for="(faq, idx) in metadata.faq" :key="idx" class="faq-item">
                <summary class="faq-question">{{ faq.q }}</summary>
                <div class="faq-answer">
                  <p>{{ faq.a }}</p>
                </div>
              </details>
            </div>
          </section>

          <!-- Footer CTA -->
          <div class="back-footer-cta">
            <NuxtLink to="/#drivers" class="btn-back-link">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
              </svg>
              Back to Drivers &amp; Hardware
            </NuxtLink>
          </div>
        </article>

        <div v-else class="error-container">
          <h2>Hardware Interface Not Found</h2>
          <p>The requested telecom transceiver could not be resolved.</p>
          <NuxtLink to="/#drivers" class="btn-back-link">Return to Drivers &amp; Hardware</NuxtLink>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { driversCatalog } from '~/data/drivers.js'
import { driversMetadata } from '~/utils/driverMetadata.js'

const route = useRoute()
const sidebarOpen = ref(false)
const { gtag } = useGtag()

// Lookup driver
const driver = driversCatalog.find(d => d.slug === route.params.slug)
const metadata = driver ? driversMetadata[driver.slug] || {
  keywords: [driver.name, 'driver install', 'telecom hardware'],
  overview: driver.desc,
  config: [`Connect device via USB interface.`, `Verify device with terminal diagnostic: ${driver.cmd}`],
  troubleshooting: "Verify USB connection state in dmesg.",
  faq: []
} : null

if (!driver) {
  throw createError({ statusCode: 404, statusMessage: 'Driver not found' })
}

// SEO and Schema.org setup
useSeoMeta({
  title: `${driver.name} Setup Guide — Telecom Security Hardware by TelcoSec`,
  description: `How to install, configure, and troubleshoot ${driver.name} drivers in TelcoChisel by TelcoSec for advanced Telecom Security and ${metadata.keywords[0]}.`,
  keywords: [...metadata.keywords, driver.name, 'TelcoSec', 'TelcoChisel', 'Telecom Security', 'udev rules', 'SDR hardware'].join(', '),
  ogTitle: `${driver.name} Setup Guide — Telecom Security Hardware by TelcoSec`,
  ogDescription: `How to install, configure, and troubleshoot ${driver.name} drivers in TelcoChisel by TelcoSec for advanced Telecom Security and ${metadata.keywords[0]}.`,
  ogType: 'article',
  ogUrl: `https://tschisel.telcosec.net/drivers/${driver.slug}`,
  ogImage: 'https://raw.githubusercontent.com/TelcoSec-Tools/TelcoChiselOS/main/assets/repo_cover.png',
  twitterCard: 'summary_large_image',
  twitterTitle: `${driver.name} Setup Guide — Telecom Security Hardware by TelcoSec`,
  twitterDescription: `How to install, configure, and troubleshoot ${driver.name} drivers in TelcoChisel by TelcoSec for advanced Telecom Security and ${metadata.keywords[0]}.`
})

const schemas = [
  defineSoftwareApp({
    name: `${driver.name} Driver`,
    applicationCategory: 'SecurityApplication',
    operatingSystem: 'Linux (Ubuntu 24.04 LTS / TelcoChisel)',
    description: driver.desc,
    url: `https://tschisel.telcosec.net/drivers/${driver.slug}`,
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'USD'
    },
    publisher: {
      '@type': 'Organization',
      name: 'TelcoSec',
      url: 'https://telcosec.net/'
    }
  })
]

if (metadata.faq && metadata.faq.length > 0) {
  schemas.push(
    defineWebPage({
      '@type': 'FAQPage',
      mainEntity: metadata.faq.map(f => ({
        '@type': 'Question',
        name: f.q,
        acceptedAnswer: {
          '@type': 'Answer',
          text: f.a
        }
      }))
    })
  )
}

useSchemaOrg(schemas)

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

  if (driver) {
    gtag('event', 'view_item', {
      currency: 'USD',
      value: 0,
      items: [{
        item_id: driver.slug,
        item_name: driver.name,
        item_category: driver.category
      }]
    })
  }
})

function tagLabel(cat) {
  return {
    transceiver: 'RF Transceiver',
    sniffing:    'Sniffer Hardware',
    reader:      'UICC Smartcard Reader'
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
.driver-meta-badges {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-top: 10px;
}

/* Section styling */
.driver-info-section {
  margin: 40px 0;
}

.driver-long-desc p {
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
