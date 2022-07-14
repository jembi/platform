// Use the "beforeRender" or "afterRender" hook
// to manipulate and control the report generation
const process = require('process')
const jsreport = require('jsreport-proxy')
const elasticsearch = await jsreport.npm.require('es7@npm:@elastic/elasticsearch@7')

const ES_USERNAME = process.env.ES_USERNAME || 'elastic'
const ES_PASSWORD = process.env.ES_PASSWORD || 'dev_password_only'
const ES_HOSTS = process.env.ES_HOSTS || 'analytics-datastore-elastic-search:9200'

const esHosts = ES_HOSTS.replace(/"/g, "")
    .split(',')
    .map(esHost => 'http://' + esHost)

async function beforeRender(req, res) {
    let resData
    try {
        var client = new elasticsearch.Client({
            node: esHosts,
            auth: {
                username: `${ES_USERNAME}`,
                password: `${ES_PASSWORD}`
            }
        })

        resData = await client.cat.health()
    } catch (err) {
        console.error(err)
        throw new Error(err)
    }

    req.data = Object.assign({}, { healthcheck: resData.body })
}
