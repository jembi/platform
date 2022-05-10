// Use the "beforeRender" or "afterRender" hook
// to manipulate and control the report generation
const axios = require('axios')

async function beforeRender (req, res) {
    const resData = await axios({
        method: 'get',
        url: `http://analytics-datastore-elastic-search:9200/_cat/health/`,
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Basic ${new Buffer(
            `elastic:dev_password_only`
            ).toString('base64')}`
        }
    })

    req.data = Object.assign({}, {healthCheck: resData.data})
}
