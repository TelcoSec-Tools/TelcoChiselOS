export const useChecklistSchema = (checklistData: {
  title: string
  description: string
  steps: { name: string, text: string }[]
}) => {

  const howToSteps = checklistData.steps.map((step, index) => ({
    '@type': 'HowToStep',
    position: index + 1,
    name: step.name,
    text: step.text
  }))

  useSchemaOrg([
    defineHowTo({
      name: checklistData.title,
      description: checklistData.description,
      step: howToSteps
    })
  ])

  useSeoMeta({
    title: `${checklistData.title} | TelcoSec Compliance`,
    description: checklistData.description,
  })
}
