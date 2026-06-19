export const useResearchArticleSchema = (articleData: {
  title: string
  description: string
  image?: string
  datePublished: string
  dateModified?: string
  specReference?: string // e.g. "3GPP TS 33.501 Clause 6.10"
  keywords?: string[]
}) => {
  
  useSchemaOrg([
    defineArticle({
      '@type': 'TechArticle',
      headline: articleData.title,
      description: articleData.description,
      image: articleData.image,
      datePublished: articleData.datePublished,
      dateModified: articleData.dateModified || articleData.datePublished,
      author: {
        name: 'Ruben Silva',
        url: 'https://www.linkedin.com/in/ruben-silva85/'
      },
      // Adding specific tech article properties
      keywords: articleData.keywords?.join(', '),
      citation: articleData.specReference 
    })
  ])

  // Automate Meta Tags
  useSeoMeta({
    title: `${articleData.title} | TelcoSec RFS`,
    description: articleData.description,
    ogTitle: articleData.title,
    ogDescription: articleData.description,
    ogImage: articleData.image,
    ogType: 'article'
  })
}
