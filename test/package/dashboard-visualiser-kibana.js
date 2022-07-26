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

describe("dashboard-visualiser-kibana", function () {
  describe("when I init the package in dev mode", async function () {
    this.timeout(5 * 60 * 1000);

    before(async function () {
      const { stderr } = await execPromise(
        "cd ../ && ./platform-linux init dashboard-visualiser-kibana --dev --env-file=.env.test"
      );
      if (stderr) console.log("stderr", stderr);
    });

    it("should have started the kibana service", async function () {
      const services = await docker.listServices({
        Filters: {
          name: "instant_dashboard-visualiser-kibana",
        },
      });
      expect(services).to.be.array();
      expect(services).to.have.lengthOf(1);
    });

    it("should have a kibana container in healthy state", async function () {
      const containers = await docker.listContainers({
        label:
          "com.docker.swarm.service.name=instant_dashboard-visualiser-kibana",
      });
      console.log(
        "🚀 ~ file: dashboard-visualiser-kibana.js ~ line 40 ~ containers",
        containers
      );
      expect(containers).to.be.array();
      expect(containers).to.have.lengthOf(1);
      containers.should.all.satisfy((container) =>
        container.Status.includes("healthy")
      );
    });
  });

  describe("when I destroy the package in dev mode", async function () {
    this.timeout(5 * 60 * 1000);

    before(async function () {
      const { stderr, stdout } = await execPromise(
        "cd ../ && ./platform-linux destroy dashboard-visualiser-kibana --dev --env-file=.env.test"
      );
      if (stderr) console.log("stderr", stderr);
    });

    it("should have removed the kibana service", async function () {
      const services = await docker.listServices({
        name: "instant_dashboard-visualiser-kibana",
      });
      expect(services).to.be.array();
      expect(services).to.be.empty;
    });

    it("should have no kibana containers remaining", async function () {
      const containers = await docker.listContainers({
        label:
          "com.docker.swarm.service.name=instant_dashboard-visualiser-kibana",
      });
      console.log(
        "🚀 ~ file: dashboard-visualiser-kibana.js ~ line 71 ~ containers",
        containers
      );
      expect(containers).to.be.array();
      expect(containers).to.be.empty;
    });
  });
});
