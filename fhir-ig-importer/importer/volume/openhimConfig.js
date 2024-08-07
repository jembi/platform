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

const jsonData = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "openhim-import.json"))
);

const appJsonData = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "ig-importer-app.json"))
);

//Substitute the url with environ variable

let url = appJsonData.url;
if (!process.env.OPENHIM_CONSOLE_BASE_URL) {
  throw new Error("Environment variable OPENHIM_CONSOLE_BASE_URL is not set");
}
let newUrl = url.replace(
  "<openhim-console-url>",
  process.env.OPENHIM_CONSOLE_BASE_URL
);

appJsonData.url = newUrl;
const data = JSON.stringify(jsonData);
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

const reqOptions = {
  ...options,
  path: "/metadata",
  method: "POST",
  headers: {
    ...options.headers,
    "Content-Length": data.length,
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

makeRequest(reqOptions, data);
makeRequest(appReqOptions, appData);
makeRequest(importMapRebuildOptions, "");
