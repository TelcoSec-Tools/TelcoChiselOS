<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="'features'" :open="sidebarOpen" @navigate="navigateHome" @toggle-theme="toggleTheme" />

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
          <NuxtLink to="/#features" class="breadcrumb-link">OS Customizations</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">{{ feature.name }}</span>
        </nav>

        <article v-if="feature" class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" :data-label="'// OS Tuning :: ' + feature.name">
            <h1 class="feature-name">{{ feature.name }}</h1>
            <div class="feature-meta-badges">
              <span class="tag" :class="categoryTagClass(feature.category)">{{ categoryTagLabel(feature.category) }}</span>
              <span class="tag status-ready">Pre-configured</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Purpose</h2>
            <div class="feature-long-desc">
              <p>{{ metadata.overview }}</p>
            </div>
          </section>

          <!-- Verification Command -->
          <section class="feature-info-section">
            <h2>Verification Command</h2>
            <p>Run the following to confirm this configuration is active on your system:</p>
            <TerminalBlock :title="feature.name + ' — Verification'" :code="feature.cmd" />
          </section>

          <!-- Configuration Steps -->
          <section class="feature-info-section">
            <h2>Configuration Details &amp; Steps</h2>
            <p>TelcoChisel applies these settings automatically at ISO build time. The following steps document each configuration item:</p>
            <ol class="numbered-guide-list">
              <li v-for="(step, idx) in metadata.config" :key="idx">
                <span class="guide-number">{{ idx + 1 }}</span>
                <div class="guide-text-block">
                  <template v-for="(part, pi) in splitCodeBlocks(step)" :key="pi">
                    <TerminalBlock v-if="part.isCode" :code="part.text" />
                    <span v-else class="guide-text">{{ part.text }}</span>
                  </template>
                </div>
              </li>
            </ol>
          </section>

          <!-- Troubleshooting -->
          <section class="feature-info-section" v-if="metadata.troubleshooting">
            <h2>Troubleshooting</h2>
            <AppCallout type="warning" title="Common Issues">
              {{ metadata.troubleshooting }}
            </AppCallout>
          </section>

          <!-- FAQs for AEO -->
          <section class="feature-info-section feature-faq-section" v-if="metadata.faq && metadata.faq.length">
            <h2>Frequently Asked Questions</h2>
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
            <NuxtLink to="/#features" class="btn-back-link">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
              </svg>
              Back to OS Customizations
            </NuxtLink>
          </div>
        </article>

        <div v-else class="error-container">
          <h2>OS Customization Not Found</h2>
          <p>The requested configuration topic could not be resolved.</p>
          <NuxtLink to="/#features" class="btn-back-link">Return to OS Customizations</NuxtLink>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { featuresCatalog } from '~/data/features.js'
import { featuresMetadata } from '~/utils/featuresMetadata.js'

const route = useRoute()
const sidebarOpen = ref(false)
const { gtag } = useGtag()

// Lookup feature
const feature = featuresCatalog.find(f => f.slug === route.params.slug)
const metadata = feature ? featuresMetadata[feature.slug] || {
  keywords: [feature.name, 'Linux OS tuning', 'TelcoChisel configuration'],
  overview: feature.desc,
  config: [`Verify the configuration is active with: ${feature.cmd}`],
  troubleshooting: null,
  faq: []
} : null

if (!feature) {
  throw createError({ statusCode: 404, statusMessage: 'Feature not found' })
}

// Split config step text into text parts and code blocks (separated by \n\n)
function splitCodeBlocks(step) {
  const parts = step.split(/\n\n(?=(?:[A-Z`#]|\/))/g)
  return parts.map((part, i) => {
    // Detect if this part looks like a code block (starts with # or /, contains = or :, or is after the first part)
    const isCode = i > 0 && (part.startsWith('#') || part.startsWith('/') || part.startsWith('net.') || part.startsWith('kernel.') || part.startsWith('fs.') || part.startsWith('vm.') || part.startsWith('GRUB') || part.startsWith('[') || part.startsWith('@') || part.startsWith('ACTION') || part.startsWith('ATTRS'))
    return { text: part.trim(), isCode }
  })
}

// SEO and Schema.org
useSeoMeta({
  title: `${feature.name} — TelcoChisel OS Configuration Guide by TelcoSec`,
  description: `How TelcoChisel by TelcoSec configures ${feature.name} for advanced Telecom Security research. ${feature.desc}`,
  keywords: [...metadata.keywords, feature.name, 'TelcoSec', 'TelcoChisel', 'Telecom Security', 'OS tuning'].join(', '),
  ogTitle: `${feature.name} — TelcoChisel OS Configuration Guide by TelcoSec`,
  ogDescription: `How TelcoChisel by TelcoSec configures ${feature.name} for advanced Telecom Security research. ${feature.desc}`,
  ogType: 'article',
  ogUrl: `https://tschisel.telcosec.net/features/${feature.slug}`,
  ogImage: 'https://raw.githubusercontent.com/TelcoSec-Tools/TelcoChiselOS/main/assets/repo_cover.png',
  twitterCard: 'summary_large_image',
  twitterTitle: `${feature.name} — TelcoChisel OS Configuration Guide by TelcoSec`,
  twitterDescription: `How TelcoChisel by TelcoSec configures ${feature.name} for advanced Telecom Security research. ${feature.desc}`
})

const schemas = [
  defineArticle({
    '@type': 'TechArticle',
    headline: `${feature.name} — TelcoChisel OS Configuration`,
    description: feature.desc,
    url: `https://tschisel.telcosec.net/features/${feature.slug}`,
    keywords: metadata.keywords.join(', '),
    author: {
      name: 'TelcoSec',
      url: 'https://telcosec.cloud/'
    },
    isPartOf: {
      '@id': 'https://tschisel.telcosec.net/#software'
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

// Navigation
function navigateHome(section) {
  sidebarOpen.value = false
  navigateTo(`/#${section}`)
}

// Theme
function toggleTheme() {
  const isLight = document.body.classList.toggle('light-theme')
  localStorage.setItem('theme', isLight ? 'light' : 'dark')
}

onMounted(() => {
  if (localStorage.getItem('theme') === 'light') document.body.classList.add('light-theme')

  if (feature) {
    gtag('event', 'view_item', {
      currency: 'USD',
      value: 0,
      items: [{
        item_id: feature.slug,
        item_name: feature.name,
        item_category: feature.category
      }]
    })
  }
})

// Category tag helpers
function categoryTagClass(cat) {
  return {
    kernel:      'tag-5g',
    network:     'tag-ran',
    security:    'tag-sim',
    hardware:    'tag-sdr',
    tools:       'tag-lte',
    environment: 'tag-ue'
  }[cat] || ''
}
function categoryTagLabel(cat) {
  return {
    kernel:      'Kernel Tuning',
    network:     'Network Stack',
    security:    'Security Hardening',
    hardware:    'Hardware Access',
    tools:       'Tool Configuration',
    environment: 'Dev Environment'
  }[cat] || cat
}
</script>

<style scoped>
/* Breadcrumbs */
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
.breadcrumb-link:hover { color: var(--amber); }
.breadcrumb-separator { color: var(--tx-faint); user-select: none; }
.breadcrumb-current { color: var(--amber); font-weight: 500; }

/* Badge row */
.feature-meta-badges {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-top: 10px;
}

/* Sections */
.feature-info-section {
  margin: 40px 0;
}
.feature-long-desc p {
  font-size: 0.95rem;
  line-height: 1.85;
  color: var(--tx);
}

/* Numbered guide list — same as driver pages */
.numbered-guide-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 20px;
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
  margin-top: 2px;
}
.guide-text-block {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.guide-text {
  font-size: 0.9rem;
  line-height: 1.7;
  color: var(--tx-dim);
}

/* FAQ */
.faq-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.faq-item {
  border: 1px solid var(--bdr);
  border-radius: 4px;
  overflow: hidden;
}
.faq-question {
  padding: 14px 18px;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--tx);
  cursor: pointer;
  list-style: none;
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: background var(--t);
}
.faq-question:hover { background: var(--bg-inset); }
.faq-item[open] .faq-question { color: var(--amber); border-bottom: 1px solid var(--bdr); }
.faq-answer {
  padding: 14px 18px;
  font-size: 0.88rem;
  line-height: 1.75;
  color: var(--tx-dim);
  background: var(--bg-card);
}

/* Back button */
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
.btn-back-link svg { transition: transform var(--t); }
.btn-back-link:hover svg { transform: translateX(-3px); }

/* Error */
.error-container { text-align: center; padding: 80px 20px; }
.error-container h2 { margin-bottom: 12px; border: none; }
</style>
