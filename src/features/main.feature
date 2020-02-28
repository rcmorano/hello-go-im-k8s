# file: main.feature
Feature: GET unspecified alphanum strings
  In order to have an API PoC
  As an API user
  I need to be able to perform GET requests to any route that is RFC compliant
  And refuse to respond any other unsupported path or method

  # know-how from: https://stackoverflow.com/a/13500078
  Scenario Outline: GET requested path as response
    When I send "GET" request to "<path>"
    And "<path>" is RFC (1738, 2396 3986) compliant 
    Then the response code should be 200 OK
    And the response should match "<path>"

    Examples:
      | path                        |
      | random-RFC-compliant-string |
      | query?string=ok             |

  # know-how from: https://stackoverflow.com/a/13500078
  Scenario Outline: GET error while requesting invalid paths
    When I send "GET" request to "<path>"
    And "<path>" is NOT (1738, 2396 3986) compliant
    Then the response code should be 400 Bad Request
    And the response should match
      """
      Bad Request
      """

    Examples:
      | path     |
      | %wtf     |
      | |nothere |

  Scenario Outline: Do not allow any other HTTP method than GET
    When I send "<method>" request to ""
    Then the response code should be 405
    And the response should match:
      """
      Method not allowed
      """

    Examples:
      | method  |
      | CONNECT |
      | DELETE  |
      | HEAD    |
      | OPTIONS |
      | PATCH   |
      | POST    |
      | PUT     |
      | TRACE   |
