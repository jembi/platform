Feature: Reverse Proxy Nginx?
    Does the Reverse Proxy Nginx package work as expected

    Scenario: Init Reverse Proxy Nginx
        Given I use parameters "init reverse-proxy-nginx --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "reverse-proxy-nginx" should be started
        And The service "reverse-proxy-nginx" should have 3 replicas
        And There should be 1 services

    Scenario: Destroy Reverse Proxy Nginx
        Given I use parameters "destroy reverse-proxy-nginx --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "reverse-proxy-nginx" should be removed
        And There should be 0 services
        And There should be 0 volumes
        And There should be 0 configs
