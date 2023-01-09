const { Given, When, Then, setDefaultTimeout } = require('@cucumber/cucumber');
setDefaultTimeout(30 * 60 * 1000);

const chai = require('chai');
const chaiArrays = require('chai-arrays');
const chaiThings = require('chai-things');
const { expect } = chai;
chai.should();
chai.use(chaiArrays);
chai.use(chaiThings);

const { launchPlatformWithParams, checkServiceStatus, checkServiceReplicasNumber, docker } = require('../../util');

Given('I use parameters {string}', function (params) {
  this.params = params;
});

When('I launch the platform with params', async function () {
  await launchPlatformWithParams(this.params);
});

Then('The service {string} should be started with {int} replicas', async function (serviceName, replicas) {
  const services = await docker.listServices({
    filters: { name: [`instant_${serviceName}`] },
  });
  const filterServicesWithExactName = services.filter((e) => e.Spec.Name === `instant_${serviceName}`);

  expect(filterServicesWithExactName).to.be.array();
  expect(filterServicesWithExactName, `${serviceName} is missing from the list of services`).to.have.lengthOf(1);

  const serviceReplicas = await checkServiceReplicasNumber(serviceName);
  expect(serviceReplicas, `Service is not replicated ${replicas} times`).to.equal(`${replicas}`);

  await checkServiceStatus(serviceName);
});

Then('There should be {int} service(s)', async function (numServices) {
  const services = await docker.listServices();
  expect(services).to.be.array();
  expect(services).to.have.lengthOf(numServices);
});

Then('There should be {int} volume(s)', async function (numVolumes) {
  const volumes = await docker.listVolumes();
  expect(volumes.Volumes).to.be.array();
  expect(volumes.Volumes).to.have.lengthOf(numVolumes);
});

Then('There should be {int} config(s)', async function (numConfigs) {
  const configs = await docker.listConfigs();
  expect(configs).to.be.array();
  expect(configs).to.have.lengthOf(numConfigs);
});

Then('The service {string} should have healthy containers', async function (serviceName) {
  const containers = await docker.listContainers();
  const serviceContainers = containers.filter(
    (container) => container.Labels['com.docker.swarm.service.name'] === `instant_${serviceName}`
  );
  expect(serviceContainers).to.be.array();
  serviceContainers.should.all.satisfy((serviceContainer) => serviceContainer.Status.includes('healthy'));
});

Then('The volume {string} should be created', async function (volumeName) {
  const volumes = await docker.listVolumes({
    filters: { name: [`instant_${volumeName}`] },
  });

  expect(volumes.Volumes).to.be.array();
  expect(volumes.Volumes).to.have.lengthOf(1);
});

Then('The service {string} should be removed', async function (serviceName) {
  const services = await docker.listServices({
    filters: { name: [`instant_${serviceName}`] },
  });
  const filterServicesWithExactName = services.filter((e) => e.Spec.Name === `instant_${serviceName}`);

  expect(filterServicesWithExactName).to.be.array();
  expect(filterServicesWithExactName).to.be.empty;
});

Then('The volume {string} should be removed', async function (volumeName) {
  const volumes = await docker.listVolumes({
    filters: { name: [`instant_${volumeName}`] },
  });

  expect(volumes.Volumes).to.be.array();
  expect(volumes.Volumes).to.be.empty;
});
