import http from "k6/http";
import { check } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://localhost:5001";

import { generateBundle } from "../resources/ips-bundle-transaction.js";

export const options = {
  scenarios: {
    volume: {
      executor: "ramping-arrival-rate",
      startRate: 10,
      timeUnit: "1s",
      preAllocatedVUs: 100,
      maxVUs: 1000,
      stages: [
        { duration: "1m", target: 100 },
        { duration: "3m", target: 500 },
        { duration: "2m", target: 1000 },
        { duration: "1m", target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.05"],
    http_req_sending: ["p(95)<10"],
    http_req_receiving: ["p(95)<10"],
    http_req_duration: ["p(95)<1000"],
  },
  noConnectionReuse: true,
  discardResponseBodies: true,
};

function makeGetRequest() {
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
  makeGetRequest();
}
