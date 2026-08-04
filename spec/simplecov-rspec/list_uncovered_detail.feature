Feature: List uncovered items detail vs. summary
  Scenario: Detailed report (the default)
    Given list_uncovered is "all"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      1 line is not covered by tests:
        ./file1.rb:1
      """

  Scenario: Summary report
    Given list_uncovered is "all" and list_uncovered_detail is false
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file1.rb | 2    |
    And the following branches are missing coverage:
      | File     | Line | Type |
      | file1.rb | 82   | else |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      2 lines are not covered by tests.
      1 branch is not covered by tests.

      Run with LIST_UNCOVERED_DETAIL=true to see the uncovered lines and branches.
      """
    And stderr output should NOT include:
      """
        ./file1.rb:1
      """

  Scenario: Summary report with nothing uncovered for one of the requested criteria
    Given list_uncovered is "all" and list_uncovered_detail is false
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      1 line is not covered by tests.

      Run with LIST_UNCOVERED_DETAIL=true to see the uncovered lines.
      """

  Scenario: Summary report with nothing uncovered at all
    Given list_uncovered is "all" and list_uncovered_detail is false
    And nothing is missing coverage
    When the at_exit_hook is called
    Then stderr output should NOT include:
      """
      is not covered by tests
      """
