Feature: Report low test coverage
  Scenario: Output low coverage report with fail message
    Given the code coverage is below the threshold
    And fail_on_low_coverage? is true
    When the at_exit_hook is called
    Then stderr output should include:
      """
      Test coverage is below the low coverage threshold of 100%
      """

  Scenario: Output low coverage report without fail message
    Given the code coverage is below the threshold
    And fail_on_low_coverage? is false
    When the at_exit_hook is called
    Then stderr output should include:
      """
      Test coverage is below the low coverage threshold of 100%
      """

  Scenario: Do not output low coverage report
    Given the code coverage is equal to the threshold
    And fail_on_low_coverage? is true
    When the at_exit_hook is called
    Then stderr output should NOT include:
      """
      Test coverage is below the low coverage threshold of
      """
