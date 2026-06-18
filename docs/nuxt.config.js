export default defineNuxtConfig({
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
