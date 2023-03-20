var Docker = require('dockerode');
var docker = new Docker();

const util = require('util');
const { exec } = require('child_process');
const execPromise = util.promisify(exec);

async function launchPlatformWithParams(params) {
  const { stdout, stderr } = await execPromise(`cd ../../ && ./instant-linux ${params}`);
  console.log('\n', stdout);
  if (stderr) console.log('stderr', stderr);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Return the service replicas number (wait time max of 5mn)
async function checkServiceReplicasNumber(serviceName, expectedReplicas) {
  let serviceCurrentReplicas = '0';
  let timeNow = Date.now();
  let timePassed = 0;
  while (serviceCurrentReplicas !== expectedReplicas) {
    const { stdout, stderr } = await execPromise(
      `docker service ls --format "{{.Name}}:{{.Replicas}}"`
    );
    if (stderr) {
      throw new Error(`Error on checking ${serviceName} replicas`, stderr);
    }

    timePassed = Date.now() - timeNow;
    const serviceStatus = stdout.split('\n').find((line) => line.includes(serviceName))
    serviceCurrentReplicas = serviceStatus.split(':')[1].split('/')[0]
    if (serviceCurrentReplicas === expectedReplicas || timePassed >= 5 * 60 * 1000) {
      return serviceCurrentReplicas;
    }

    await sleep(1000);
  }
}

// Service should have Running status for 5 seconds
async function checkServiceStatus(serviceName) {
  let serviceStatuses = '';
  let timeNow = Date.now();
  let timePassedWithRunningStatus = 0;
  const services = await docker.listServices();
  const serviceNames = services.map((service) => service.Spec.Name);
  while (!serviceStatuses.includes('Running') || timePassedWithRunningStatus < 5 * 1000) {
    const { stdout, stderr } = await execPromise(
      `docker service ps ${serviceNames.find(name => name.includes(serviceName))} --format "{{.CurrentState}}"`
    );
    if (stderr) {
      throw new Error(`Error on checking ${serviceName} status`, stderr);
    }

    serviceStatuses = stdout;
    if (serviceStatuses.includes('Running')) {
      timePassedWithRunningStatus = Date.now() - timeNow;
    } else if (Date.now() - timeNow > 5 * 1000) {
      throw new Error(`${serviceName} is not in a stable status`);
    }

    await sleep(1000);
  }
}

const filterServicesWithExactName = async (serviceName) => {
  const services = await docker.listServices();
  const serviceNames = services.map((service) => service.Spec.Name.substring(service.Spec.Name.indexOf('_') + 1));
  return serviceNames.filter((e) => e === serviceName);
};

module.exports = {
  launchPlatformWithParams,
  checkServiceStatus,
  checkServiceReplicasNumber,
  filterServicesWithExactName,
  docker,
};
