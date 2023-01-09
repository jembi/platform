var Docker = require('dockerode');
var docker = new Docker();

const util = require('util');
const { exec } = require('child_process');
const execPromise = util.promisify(exec);

async function launchPlatformWithParams(params) {
  const { stdout, stderr } = await execPromise(`cd ../../ && ./platform-linux ${params}`);
  console.log('\n', stdout);
  if (stderr) console.log('stderr', stderr);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Return the service replicas number
async function checkServiceReplicasNumber(serviceName) {
  const { stdout, stderr } = await execPromise(
    `docker service ls --filter name=instant_${serviceName} --format "{{.Replicas}}"`
  );
  if (stderr) {
    throw new Error(`Error on checking ${serviceName} replicas`, stderr);
  }

  return stdout.split('/')[0];
}

// Service should have Running status for 5 seconds
async function checkServiceStatus(serviceName) {
  let serviceStatuses = '';
  let timeNow = Date.now();
  let timePassedWithRunningStatus = 0;
  while (!serviceStatuses.includes('Running') || timePassedWithRunningStatus < 5 * 1000) {
    const { stdout, stderr } = await execPromise(
      `docker service ps instant_${serviceName} --format "{{.CurrentState}}"`
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

module.exports = {
  launchPlatformWithParams,
  checkServiceStatus,
  checkServiceReplicasNumber,
  docker,
};
