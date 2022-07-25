const chai = require("chai");
const chaiArrays = require("chai-arrays");
const chaiThings = require("chai-things");
const { expect } = chai;
chai.should();
chai.use(chaiArrays);
chai.use(chaiThings);

const util = require("util");
const { exec } = require("child_process");
const execPromise = util.promisify(exec);

var Docker = require("dockerode");
var docker = new Docker();

describe("analytics-datastore-elastic-search", function () {
  describe("when I init the package in dev mode", async function () {
    this.timeout(5 * 60 * 1000);

    before(async function () {
      const { stderr } = await execPromise(
        "cd ../ && ./platform-linux init analytics-datastore-elastic-search --dev --env-file=.env.local"
      );
      if (stderr) console.log("stderr", stderr);
    });

    it("should have started the elastic service", async function () {
      const services = await docker.listServices({
        name: "instant_analytics-datastore-elastic-search",
      });
      expect(services).to.be.array();
      expect(services).to.have.lengthOf(1);
    });

    it("should have an elastic container in healthy state", async function () {
      const containers = await docker.listContainers({
        label:
          "com.docker.swarm.service.name=instant_analytics-datastore-elastic-search",
      });
      expect(containers).to.be.array();
      expect(containers).to.have.lengthOf(1);
      containers.should.all.satisfy((container) =>
        container.Status.includes("healthy")
      );
    });

    it("should have created an elastic volume", async function () {
      const volumes = await docker.listVolumes({ name: "instant_es-data" });
      expect(volumes.Volumes).to.be.array();
      expect(volumes.Volumes).to.have.lengthOf(1);
    });
  });

  describe("when I destroy the package in dev mode", async function () {
    this.timeout(5 * 60 * 1000);

    before(async function () {
      const { stderr } = await execPromise(
        "cd ../ && ./platform-linux destroy analytics-datastore-elastic-search --dev --env-file=.env.local"
      );
      if (stderr) console.log("stderr", stderr);
    });

    it("should have removed the elastic service", async function () {
      const services = await docker.listServices({
        name: "instant_analytics-datastore-elastic-search",
      });
      expect(services).to.be.array();
      expect(services).to.be.empty;
    });

    it("should have no elastic containers remaining", async function () {
      const containers = await docker.listContainers({
        label:
          "com.docker.swarm.service.name=instant_analytics-datastore-elastic-search",
      });
      expect(containers).to.be.array();
      expect(containers).to.be.empty;
    });

    it("should have removed the elastic volume", async function () {
      const volumes = await docker.listVolumes({ name: "instant_es-data" });
      expect(volumes).to.be.array();
      expect(volumes).to.be.empty;
    });
  });
});
