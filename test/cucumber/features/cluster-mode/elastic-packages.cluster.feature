Feature: Analytics Datastore Elasticsearch - Dashboard Visualiser Kibana - Data Mapper Logstash ?
    Does the ELK stack work as expected

  Scenario: Init Dashboard Visualiser Kibana
    Given I use parameters "package init -n=dashboard-visualiser-kibana --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "analytics-datastore-elastic-search-01" should be started with 1 replica
    And The service "analytics-datastore-elastic-search-01" should be connected to the networks
      | elastic_public |
    And The service "analytics-datastore-elastic-search-02" should be started with 1 replica
    And The service "analytics-datastore-elastic-search-02" should be connected to the networks
      | elastic_public |
    And The service "analytics-datastore-elastic-search-03" should be started with 1 replica
    And The service "analytics-datastore-elastic-search-03" should be connected to the networks
      | elastic_public |
    And The service "dashboard-visualiser-kibana" should be started with 1 replica
    And The service "dashboard-visualiser-kibana" should be connected to the networks
      | reverse-proxy_public | elastic_public | kibana_default |
    And The service "elastic-search-config-importer" should be removed
    And The service "kibana-config-importer" should be removed
    And There should be 4 services
    And The service "dashboard-visualiser-kibana" should have healthy containers

  Scenario: Init Data Mapper Logstash
    Given I use parameters "package init -n=data-mapper-logstash --dev --only --env-file=.env.cluster"
    When I launch the platform with params
    And The service "data-mapper-logstash" should be started with 3 replicas
    And The service "data-mapper-logstash" should be connected to the networks
      | kafka_public | elastic_public |  
    And There should be 5 services
    And The service "data-mapper-logstash" should have healthy containers

  Scenario: Destroy ELK stack
    Given I use parameters "package destroy -n=dashboard-visualiser-kibana,data-mapper-logstash --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "analytics-datastore-elastic-search-01" should be removed
    And The service "analytics-datastore-elastic-search-02" should be removed
    And The service "analytics-datastore-elastic-search-03" should be removed
    And The service "dashboard-visualiser-kibana" should be removed
    And The service "data-mapper-logstash" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | elastic_public | kafka_public | reverse-proxy_public |
