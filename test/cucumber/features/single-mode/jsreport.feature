Feature: Dashboard Visualiser Jsreport?
    Does the Dashboard Visualiser Jsreport package work as expected

    Scenario: Init Dashboard Visualiser Jsreport
        Given I use parameters "init dashboard-visualiser-jsreport --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "dashboard-visualiser-jsreport" should be started with 1 replica
        And There should be 1 service
        And The service "dashboard-visualiser-jsreport" should have healthy containers

    Scenario: Destroy Dashboard Visualiser Jsreport
        Given I use parameters "destroy dashboard-visualiser-jsreport --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "dashboard-visualiser-jsreport" should be removed
        And There should be 0 service
        And There should be 0 volume
        And There should be 0 config