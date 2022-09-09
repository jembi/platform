var Docker = require("dockerode");
var docker = new Docker();

const util = require("util");
const { exec } = require("child_process");
const execPromise = util.promisify(exec);

async function launchPlatformWithParams(params) {
  const { stderr } = await execPromise(
    `cd ../../ && ./platform-linux ${params}`
  );
  if (stderr) console.log("stderr", stderr);
}

module.exports = {
  launchPlatformWithParams,
  docker,
};
