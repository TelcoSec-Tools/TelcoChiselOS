import { toolsCatalog } from './data/tools.js'
import { featuresCatalog } from './data/features.js'
import { driversCatalog } from './data/drivers.js'

const dynamicRoutes = [
  ...toolsCatalog.map(t => `/tools/${t.slug}`),
  ...Array.from(new Set(toolsCatalog.map(t => t.category))).map(c => `/tools/category/${c}`),
  ...featuresCatalog.map(f => `/features/${f.slug}`),
  ...driversCatalog.map(d => `/drivers/${d.slug}`)
]

export default defineNuxtConfig({
  unhead: {
    legacy: false
  },
  app: {
    baseURL: '/',
    head: {
      htmlAttrs: { lang: 'en' },
      link: [
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,300;0,400;0,500;0,600;1,400&family=Barlow+Condensed:wght@300;400;600;700;900&display=swap',
          crossorigin: 'anonymous'
        }
      ]
    }
  },

  css: ['~/assets/main.css'],

  modules: [
    '@nuxtjs/seo',
    'nuxt-gtag',
    'nuxt-ai-ready'
  ],

  aiReady: {
    indexNow: {
      key: '8f6412f9b8c24d9f8e45c7b3f9a2b7f3'
    }
  },

  gtag: {
    id: 'G-HJSSZ9QBCC' // Replace with actual Google Analytics Measurement ID
  },

  site: {
    url: 'https://tschisel.telcosec.net',
    name: 'TelcoChisel',
    description: 'TelcoChisel by TelcoSec is the ultimate free bootable Linux OS for advanced Telecom Security research. Ships with 75+ tools for SDR analysis and cellular penetration testing.',
    defaultLocale: 'en',
  },

  schemaOrg: {
    identity: {
      type: 'Organization',
      name: 'TelcoSec',
      url: 'https://www.telco-sec.com/',
      logo: 'https://cdn.telco-sec.com/logo.png'
    }
  },

  sitemap: {
    zeroRuntime: true,
    urls: dynamicRoutes
  },

  nitro: {
    preset: 'static',
    prerender: {
      crawlLinks: true,
      routes: ['/', ...dynamicRoutes]
    }
  },

  experimental: {
    payloadExtraction: false
  }
})
