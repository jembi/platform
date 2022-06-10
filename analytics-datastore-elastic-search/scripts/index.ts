import path from "path";
import fs from "fs";
import Docker from "dockerode";
import { exec } from "child_process";

interface Args {
  ACTION: string;
  MODE: string;
  STATEFUL_NODES: string;
  PROJECT_ROOT: string;
  PACKAGE_ROOT: string;
  PACKAGE_NAME: string;
  docker: Docker;
}

const Bash = (command: string) => {
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`error: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`stderr: ${stderr}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
  });
};

const GetPackageMetadata = (packageRoot: string) => {
  const packageMetadataFile: any = fs.readFileSync(path.join(packageRoot, "package-metadata.json"));
  return JSON.parse(packageMetadataFile);
};

const GetComposeFiles = (packageRoot, mode, statefulNodes) => {
  let composeFiles = [path.join(packageRoot, "docker-compose.yml")];
  if (mode === "dev") {
    composeFiles = [...composeFiles, path.join(packageRoot, "docker-compose.dev.yml")];
  }
  if (statefulNodes === "cluster") {
    composeFiles = [...composeFiles, path.join(packageRoot, "docker-compose.cluster.yml")];
  }
  return composeFiles;
};

const StackDeploy = (composeFiles, stackName = "instant") => {
  Bash(`docker stack deploy -c ${composeFiles.join(` -c `)} ${stackName}`);
};

const AwaitContainerStartup = async (docker: Docker, containerIdentifier: string) => {
  let containerFound = false;
  do {
    const containers = await docker.listContainers();
    containerFound = containers.some((container) => container.Id === containerIdentifier);
  } while (!containerFound);
  const container = docker.getContainer(containerIdentifier);
};

const AwaitContainerRunning = async (docker: Docker, containerIdentifier: string) => {
  let containerState = "";
  do {
    const container = docker.getContainer(containerIdentifier);
    let containerInspect = await container.inspect();
    containerState = containerInspect?.State?.Status;
  } while (containerState !== "running");
  console.log("Container is running");
};

const init = async ({ PACKAGE_ROOT, MODE, STATEFUL_NODES, docker }: Args) => {
  const composeFiles = GetComposeFiles(PACKAGE_ROOT, MODE, STATEFUL_NODES);
  StackDeploy(composeFiles);
  console.info("Waiting for elasticsearch to start before automatically setting built-in passwords...");

  await AwaitContainerStartup(docker, "instant_analytics-datastore-elastic-search");
  await AwaitContainerRunning(docker, "instant_analytics-datastore-elastic-search");
};

const up = ({ PACKAGE_ROOT, MODE, STATEFUL_NODES }: Args) => {
  const composeFiles = GetComposeFiles(PACKAGE_ROOT, MODE, STATEFUL_NODES);
  StackDeploy(composeFiles);
};

const down = ({ docker }: Args) => {
  Bash("docker service scale instant_analytics-datastore-elastic-search=0");
};

const destroy = async ({ STATEFUL_NODES, docker }: Args) => {
  await docker.getService("instant_analytics-datastore-elastic-search").remove();
  // await docker.getContainer("instant_analytics-datastore-elastic-search").wait({ condition: "removed" });
  await docker.getVolume("instant_es-data").remove();
  if (STATEFUL_NODES === "cluster") console.info("Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted");
};

const main = async () => {
  const [cmd, index, ACTION, MODE = "PROD"] = process.argv;
  const { STATEFUL_NODES = "cluster" } = process.env;

  const PROJECT_ROOT = path.join(__dirname, "../../../");
  const PACKAGE_ROOT = path.join(__dirname, "../../");
  const PACKAGE_NAME = GetPackageMetadata(PACKAGE_ROOT)?.id;

  const docker = new Docker({ socketPath: "/var/run/docker.sock" });

  const args: Args = {
    ACTION,
    MODE,
    STATEFUL_NODES,
    PROJECT_ROOT,
    PACKAGE_ROOT,
    PACKAGE_NAME,
    docker,
  };

  console.info(`Running Analytics Datastore Elastic Search package in ${STATEFUL_NODES.toUpperCase()} node mode`);
  console.info(`Running Analytics Datastore Elastic Search package in ${MODE.toUpperCase()} node mode`);

  switch (ACTION) {
    case "init":
      await init(args);
      break;

    case "up":
      up(args);
      break;

    case "down":
      down(args);
      break;

    case "destroy":
      await destroy(args);
      break;

    default:
      console.log("Valid options are: init, up, down, or destroy");
      break;
  }
};

main();
