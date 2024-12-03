import http from "k6/http";
import { check } from "k6";
import { generateBundle } from "../resources/ips-bundle-transaction.js";

const BASE_URL = __ENV.BASE_URL || "http://localhost:5001";

export const options = {
  scenarios: {
    load: {
      executor: "constant-arrival-rate",
      rate: 30,
      timeUnit: "1s",
      duration: "1m",
      preAllocatedVUs: 1,
      maxVUs: 2,
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_sending: ["p(95)<20"],
    http_req_receiving: ["p(95)<20"],
    http_req_duration: ["p(95)<1000"],
  },
  noVUConnectionReuse: false,
  discardResponseBodies: false,
};

function makePostRequest() {
  const data = generateBundle();

  const response = http.post(`${BASE_URL}/fhir`, JSON.stringify(data[0]), {
    headers: {
      "Content-Type": "application/fhir+json",
      Accept: "application/json",
      Authorization: "Custom test",
    },
    tags: {
      name: "POST Bundle",
    },
  });
  check(response, {
    "status code is 200": (r) => r.status === 200,
  });
}

export default function () {
  makePostRequest();
}
