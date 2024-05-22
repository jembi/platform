const fs = require("fs");
const https = require("https");
const path = require("path");

("use strict");

const OPENHIM_CORE_SERVICE_NAME = "openhim-core";
const OPENHIM_MEDIATOR_API_PORT = 8080;
const OPENHIM_API_PASSWORD = process.env.OPENHIM_API_PASSWORD || "instant101";
const OPENHIM_API_USERNAME =
  process.env.OPENHIM_API_USERNAME || "root@openhim.org";

const authHeader = Buffer.from(
  `${OPENHIM_API_USERNAME}:${OPENHIM_API_PASSWORD}`
).toString("base64");
function makeRequest(options, data) {
  const req = https.request(options, (res) => {
    if (res.statusCode == 401) {
      throw new Error(`Incorrect OpenHIM API credentials`);
    }

    if (![201, 200].includes(res.statusCode)) {
      throw new Error(`Failed to import OpenHIM config: ${res.statusCode}`);
    }

    console.log("Successfully Imported OpenHIM Config");
  });

  req.on("error", (error) => {
    throw new Error(`Failed to import OpenHIM config: ${error}`);
  });

  req.write(data);
  req.end();
}

const appJsonData = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "reprocessor-ui-app.json"))
);
const appData = JSON.stringify(appJsonData);

const options = {
  protocol: "https:",
  hostname: OPENHIM_CORE_SERVICE_NAME,
  port: OPENHIM_MEDIATOR_API_PORT,
  headers: {
    "Content-Type": "application/json",
    Authorization: `Basic ${authHeader}`,
  },
};

const appReqOptions = {
  ...options,
  path: "/apps",
  method: "POST",
  headers: {
    ...options.headers,
    "Content-Length": appData.length,
  },
};

const importMapRebuildOptions = {
  ...options,
  path: "/apps",
  method: "GET",
  headers: {
    ...options.headers,
  },
};

makeRequest(appReqOptions, appData);
makeRequest(importMapRebuildOptions, "");
