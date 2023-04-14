Feature: Reverse Proxy Nginx?
    Does the Reverse Proxy Nginx package work as expected

  Scenario: Init Reverse Proxy Nginx
    Given I use parameters "package init -n=reverse-proxy-nginx --env-file=.env.local"
    When I launch the platform with params
    Then The service "reverse-proxy-nginx" should be started with 1 replica
    And There should be 1 service
    And The service "reverse-proxy-nginx" should be connected to the networks
      | reverse-proxy_public |

  Scenario: Destroy Reverse Proxy Nginx
    Given I use parameters "package destroy -n=reverse-proxy-nginx --env-file=.env.local"
    When I launch the platform with params
    Then The service "reverse-proxy-nginx" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | reverse-proxy_public |
