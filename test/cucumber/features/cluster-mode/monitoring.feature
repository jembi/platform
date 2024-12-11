Feature: Monitoring package?
  Does the Monitoring package work as expected

  Scenario: Init Monitoring
    Given I use parameters "package init -n=monitoring --only --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "grafana" should be started with 1 replica
    And The service "grafana" should be connected to the networks
      | reverse-proxy_public | keycloak_public | monitoring_default |
    And The service "prometheus" should be started with 1 replica
    And The service "prometheus" should be connected to the networks
      | prometheus_public | monitoring_default |
    And The service "cadvisor" should be started with 3 replica
    And The service "node-exporter" should be started with 3 replica
    And The service "loki" should be started with 1 replica
    And The service "promtail" should be started with 3 replica
      | reverse-proxy_public | monitoring_default |
    And The service "prometheus_backup" should be started with 1 replica
    And The service "prometheus_backup" should be connected to the networks
      | prometheus_public | monitoring_default |

  Scenario: Destroy Monitoring package
    Given I use parameters "package destroy -n=monitoring --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "grafana" should be removed
    And The service "prometheus" should be removed
    And The service "cadvisor" should be removed
    And The service "node-exporter" should be removed
    And The service "loki" should be removed
    And The service "promtail" should be removed
    And The service "prometheus_backup" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | prometheus_public | keycloak_public | reverse-proxy_public |
