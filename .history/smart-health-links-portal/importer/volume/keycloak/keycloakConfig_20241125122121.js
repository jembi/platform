const http = require('http');
const path = require('path');
const fs = require('fs');

// Keycloak configuration
const keycloakUrl = 'http://localhost'; // http://identity-access-manager-keycloak
const keycloakPort = 9088;

const adminUsername = "admin"// process.env.KEYCLOAK_ADMIN;
const adminPassword = "dev_password_only" //process.env.KEYCLOAK_ADMIN_PASSWORD;

// Load realm configuration from JSON file
let realmConfig = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'keycloak-realm.json'), 'utf8')
);

function replacePlaceholders(obj) {
  const nextAuthUrl = process.env.NEXTAUTH_URL || 'http://localhost'
  const shlpKeycloakClientSecret = process.env.KEYCLOAK_CLIENT_SECRET || 'client_secret'

  for (let key in obj) {
    if (typeof obj[key] === 'object') {
      replacePlaceholders(obj[key]);
    } else if (typeof obj[key] === 'string') {
      obj[key] = obj[key].replace(/<NEXTAUTH_URL>/g, nextAuthUrl);
      obj[key] = obj[key].replace(/<KEYCLOAK_CLIENT_SECRET>/g, shlpKeycloakClientSecret);
    }
  }
}

function makeAsyncRequest(options, data) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      res.setEncoding('utf8');
      let responseBody = '';

      res.on('data', (chunk) => {
        responseBody += chunk;
      });

      res.on('end', () => {
        resolve({
          message: responseBody ? JSON.parse(responseBody) : null,
          status: res.statusCode
        });
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (data) {
      req.write(data)
    }

    req.end();
  });
}

const getAccessToken = async () => {
  // Get an admin access token
  const tokenOptions = {
    hostname: keycloakUrl.replace('http://', '').replace('https://', ''),
    port: keycloakPort,
    path: '/realms/master/protocol/openid-connect/token',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  };
  const tokenRequestData = new URLSearchParams({
    grant_type: 'password',
    client_id: 'admin-cli',
    username: adminUsername,
    password: adminPassword
  }).toString();
  const accessToken = await makeAsyncRequest(tokenOptions, tokenRequestData);

  if (accessToken.status !== 200) {
    throw new Error("Could not retrieve access token")
  }

  return accessToken.message.access_token;
}

const doesRealmExist = async (config) => {
  const realmOptions = {
    hostname: keycloakUrl.replace('http://', '').replace('https://', ''),
    port: keycloakPort,
    path: `/admin/realms/${config.realm}`,
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${config.token}`,
      'Content-Type': 'application/json'
    }
  };

  const res = await makeAsyncRequest(realmOptions)

  // return true if status is 200 - found
  return res.status === 200;
}

const createOrUpdateRealm = async (config, realmExist, data) => {
  const realmOptions = {
    hostname: keycloakUrl.replace('http://', '').replace('https://', ''),
    port: keycloakPort,
    path: realmExist ? `/admin/realms/${config.realm}` : `/admin/realms`,
    method: realmExist ? 'PUT' : 'POST',
    headers: {
      'Authorization': `Bearer ${config.token}`,
      'Content-Type': 'application/json'
    }
  };

  return await makeAsyncRequest(realmOptions, JSON.stringify(data));
}

(async () => {
  console.log('My Async ran')
  // replace placeholder for pointing the correct instance
  replacePlaceholders(realmConfig);

  // get the keycloak access token
  const token = await getAccessToken()

  // check if realm already exists - to perform an update instead of create
  const config = { token, realm: realmConfig.realm }
  const realmExists = await doesRealmExist({ token, realm: realmConfig.realm })
  console.log(realmExists)

  const updateCreateRealmRes = await createOrUpdateRealm(config, realmExists, realmConfig)

  if ([201, 204].includes(updateCreateRealmRes.status)) {
    // successfully created or updated
    console.log('Successfully created or updated Realm settings')
  } else {
    console.error('Something went wrong with the keycloak config update: ', updateCreateRealmRes)
  }

  // await new Promise(resolve => setTimeout(resolve, 60000)); 
})();
