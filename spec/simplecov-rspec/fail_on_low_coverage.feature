Feature: Fail on low test coverage
  Scenario: Fail RSpec
    Given the code coverage is below the threshold
    And fail_on_low_coverage? is true
    When the at_exit_hook is called
    Then a SystemExit exception should be raised with a non-zero status code

  Scenario: Do not fail RSpec
    Given the code coverage is equal to the threshold
    And fail_on_low_coverage? is true
    When the at_exit_hook is called
    Then a SystemExit exception should not be raised

    Given the code coverage is below the threshold
    And fail_on_low_coverage? is false
    When the at_exit_hook is called
    Then a SystemExit exception should not be raised
