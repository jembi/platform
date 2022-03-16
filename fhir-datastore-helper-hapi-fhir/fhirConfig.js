'use strict'

const axios = require('axios').default
const AdmZip = require('adm-zip')

const HAPI_FHIR_BASE_URL = process.env.HAPI_FHIR_BASE_URL
const FHIR_IG_URL = process.env.FHIR_IG_URL
const resourceTypes = ['CodeSystem', 'ConceptMap', 'ValueSet']

const createOrUpdateResource = ({resourceName, data}) =>
  new Promise((resolve, reject) => {
    const url = `${HAPI_FHIR_BASE_URL}/${resourceName}/${JSON.parse(data).id}`

    axios
      .put(url, JSON.parse(data))
      .then(() => resolve(`Successfully created ${resourceName} resource`))
      .catch(err => reject(`${resourceName} resource creation failed: ${err}`))
  })

const getResources = async url => {
  const response = await axios.get(url, {responseType: 'arraybuffer'})
  const zip = AdmZip(response.data)
  return zip
    .getEntries()
    .filter(
      entry =>
        entry.entryName.endsWith('.json') &&
        !entry.entryName.startsWith('ImplementationGuide')
    )
}

const findMatch = ({file, resourceTypes}) => {
  const regex = new RegExp(resourceTypes.join('|'), 'g')
  const match = file.match(regex)
  return match ? match[0] : null
}

const buildResourceCollectionsObject = ({files, resourceTypes}) => {
  const result = Object.create({Other: []})
  resourceTypes.forEach(resourceType => {
    result[resourceType] = []
  })

  files.forEach(file => {
    const match = findMatch({file: file.entryName, resourceTypes})
    result[match ? match : 'Other'].push(file)
  })

  return result
}

const getResourceType = ({file, resourceTypes}) => {
  const match = findMatch({file, resourceTypes})
  return match || file.split(/-/)[0]
}

async function sendResources(resources) {
  if (!resources.length) return

  const resource = resources.pop()
  const resourceName = getResourceType({
    file: resource.entryName,
    resourceTypes
  })
  const data = resource.getData().toString('utf-8')
  await createOrUpdateResource({resourceName, data})

  await sendResources(resources)
}

;(async () => {
  const resources = await getResources(`${FHIR_IG_URL}/definitions.json.zip`)
  const resourceCollections = buildResourceCollectionsObject({
    files: resources,
    resourceTypes
  })

  try {
    await sendResources(
      resourceCollections['Other'].concat(
        resourceCollections['ValueSet'],
        resourceCollections['CodeSystem'],
        resourceCollections['ConceptMap']
      )
    )
    console.log('Posting of Resources resources to Hapi FHIR successfully done')
  } catch (err) {
    console.log(err)
  }
})()
