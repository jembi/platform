Feature: Dashboard Visualiser Superset?
    Does the Dashboard Visualiser Superset package work as expected

    Scenario: Init Dashboard Visualiser Superset
        Given I use parameters "init dashboard-visualiser-superset --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "dashboard-visualiser-superset" should be started with 1 replica
        And The service "superset-config-importer" should be removed
        And The service "ddashboard-visualiser-superset" should have healthy containers
        And There should be 1 service
        And There should be 3 volumes

    Scenario: Destroy Dashboard Visualiser Superset
        Given I use parameters "destroy dashboard-visualiser-superset --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "dashboard-visualiser-superset" should be removed
        And There should be 0 service
        And There should be 0 volume
        And There should be 0 config
