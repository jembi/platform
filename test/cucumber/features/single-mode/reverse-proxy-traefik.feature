Feature: Reverse Proxy Traefik?
    Does the Reverse Proxy Traefik package work as expected

  Scenario: Init Reverse Proxy Traefik
    Given I use parameters "package init -n=reverse-proxy-traefik --env-file=.env.local"
    When I launch the platform with params
    Then The service "reverse-proxy-traefik" should be started with 1 replica
    And There should be 1 service
    And The service "reverse-proxy-traefik" should be connected to the networks
      | reverse-proxy-traefik_public |

  Scenario: Destroy Reverse Proxy Traefik
    Given I use parameters "package destroy -n=reverse-proxy-traefik --env-file=.env.local"
    When I launch the platform with params
    Then The service "reverse-proxy-traefik" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | reverse-proxy-traefik_public |
