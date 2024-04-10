"use strict"

const axios = require("axios");
const fs = require("fs");
const path = require('path');
const chai = require("chai");
const { ClickHouse } = require('clickhouse');
const { Given, When, Then, setDefaultTimeout } = require("@cucumber/cucumber");
setDefaultTimeout(30 * 60 * 1000);

const CLICKHOUSE_HOST =
  process.env.CLICKHOUSE_HOST || 'localhost';
const CLICKHOUSE_PORT = parseInt(process.env.CLICKHOUSE_PORT || '8124');
const CLICKHOUSE_DEBUG = Boolean(process.env.CLICKHOUSE_DEBUG || false);

const { expect } = chai;

const clickhouse = new ClickHouse({
  url: CLICKHOUSE_HOST,
  port: CLICKHOUSE_PORT,
  debug: CLICKHOUSE_DEBUG,
  raw: true,
});

const query = table => `SELECT * FROM ${table}`;

const sendRequest = (url, method='POST', data={}) => {
  return axios({
    url,
    headers: {
      'Content-Type': 'application/fhir+json',
      Authorization: `Custom test`
    },
    data,
    method
  })
};

let PatientID;

Given("I have configured the cdr", async function () {
  const organization = JSON.parse(
    fs.readFileSync(path.resolve(__dirname, '..' , 'resources', 'organization.json'))
  );

  this.cdrConfigResult = await sendRequest('http://localhost:5001/fhir', 'POST', organization);
});

When("I send a fhir patient bundle", async function () {
  const fhirBundle = JSON.parse(
    fs.readFileSync(path.resolve(__dirname, '..' , 'resources', 'fhirBundle.json'))
  );

  this.fhirBundleSentResult = await sendRequest('http://localhost:5001/fhir', 'POST', fhirBundle);
});

When("I then send a fhir patient summary request", async function () {
  this.IPSResult = await sendRequest(`http://localhost:5001/fhir/Patient/${PatientID}/$summary`, 'GET');
});

When("I then send a request for all the patient's clinical data", async function () {
  this.EverythingResult = await sendRequest(`http://localhost:5001/fhir/Patient/${PatientID}/$everything`, 'GET');
});

Then("the clinical data should be stored in hapi fhir", async function () {
  this.fhirBundleSentResult.data.entry.forEach(rec => {
    expect(rec.response.status).to.match(/201|200/);
  });
});

Then("the patient data in the Jempi client registry", async function () {
  const patientResource = this.fhirBundleSentResult.data.entry.filter(rec => rec.response.location.match('Patient'))[0];

  PatientID = patientResource.response.location.split('/')[1];

  const patient = await sendRequest(`http://localhost:3003/fhir/links/Patient/${PatientID}`, 'GET');

  expect(patient.data.link.filter(pat => pat.other.reference.match(`Patient/${PatientID}`)).length).to.equal(1);
});

Then("I should get a successful summary response", function () {
  expect(this.IPSResult.data.total).to.be.greaterThan(0);
});

Then("I should get a successful everything response", function () {
  expect(this.EverythingResult.data.total).to.be.greaterThan(0);
});

Then("a request to fetch data from the cdr should fail", async function () {
  await sendRequest(`http://localhost:3003/fhir/links/Patient/${PatientID}`).catch(err => {
    expect(err.message).to.match(/ECONNREFUSED/);
  });
});

Then("the data should be stored in clickhouse", async function () {
  const patient = await clickhouse.query(
    query("patient_example"),
  ).toPromise();
  const observation = await clickhouse.query(
    query("observation_example")
  ).toPromise();


  expect(JSON.parse(patient).rows).to.be.greaterThan(0);
  expect(JSON.parse(observation).rows).to.be.greaterThan(0);
});
