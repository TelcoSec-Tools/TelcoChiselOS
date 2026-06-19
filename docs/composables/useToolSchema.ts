export const useToolSchema = (toolData: {
  name: string
  description: string
  category: string
  slug?: string
  isFree?: boolean
  offers?: any
  faq?: { q: string, a: string }[]
  keywords?: string[]
}) => {
  // Setup standard meta tags
  useSeoMeta({
    title: `${toolData.name} Guide — 5G/4G Telecom Security | TelcoChisel`,
    description: toolData.description,
    ogTitle: `${toolData.name} Guide — 5G/4G Telecom Security | TelcoChisel`,
    ogDescription: toolData.description,
    ogType: 'article',
    ogUrl: `https://tschisel.telcosec.net/tools/${toolData.slug || ''}`,
    ogImage: 'https://raw.githubusercontent.com/TelcoSec/TelcoChisel/main/assets/repo_cover.png',
    twitterCard: 'summary_large_image',
  })

  // Use useSchemaOrg composable
  const schemas = [
    defineSoftwareApp({
      name: toolData.name,
      description: toolData.description,
      applicationCategory: toolData.category,
      operatingSystem: 'Linux (Ubuntu 24.04 LTS / TelcoChisel)',
      url: `https://tschisel.telcosec.net/tools/${toolData.slug || ''}`,
      offers: toolData.offers || {
        '@type': 'Offer',
        price: toolData.isFree ? '0' : undefined,
        priceCurrency: 'USD'
      }
    })
  ]

  // Conditionally add FAQ Schema if provided
  if (toolData.faq && toolData.faq.length > 0) {
    schemas.push(
      defineWebPage({
        '@type': 'FAQPage',
        mainEntity: toolData.faq.map(f => ({
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
}
