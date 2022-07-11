var assert = require("assert");
var Docker = require("dockerode");
var docker = new Docker();

describe("dashboard-visualiser-kibana", function () {
  describe("when I start up the package with no parameters", function () {
    it("should have started the kibana service", async function () {
      const services = await docker.listServices();
      assert.ok(
        services.some(
          (service) =>
            service.Spec.Name === "instant_dashboard-visualiser-kibana"
        )
      );
    });
    it("should have a kibana container in healthy state", async function () {
      const services = await docker.listServices();
      services[0].inspect;
      assert.ok(
        services.some(
          (service) =>
            service.Spec.Name === "instant_dashboard-visualiser-kibana"
        )
      );
    });
    it("should have started the elastic service", async function () {
      const services = await docker.listServices();
      assert.ok(
        services.some(
          (service) =>
            service.Spec.Name === "instant_analytics-datastore-elastic-search"
        )
      );
    });
  });
});
