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
    '@nuxtjs/seo'
  ],

  site: {
    url: 'https://library.telcosec.net',
    name: 'TelcoSec Library',
    description: 'TelcoSec Threat Intelligence, Research & Documentation',
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

  nitro: {
    preset: 'static',
    prerender: {
      crawlLinks: true,
      routes: ['/']
    }
  },

  experimental: {
    payloadExtraction: false
  }
})
