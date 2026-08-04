Feature: List uncovered items
  Scenario: Output the uncovered lines report (a single line)
    Given list_uncovered is "line"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      1 line is not covered by tests:
        ./file1.rb:1
      """

  Scenario: Output the uncovered lines report (>1 lines)
    Given list_uncovered is "line"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file1.rb | 2    |
      | file2.rb | 3    |
      | file3.rb | 4    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      4 lines are not covered by tests:
        ./file1.rb:1
        ./file1.rb:2
        ./file2.rb:3
        ./file3.rb:4
      """

  Scenario: Output the uncovered branches report
    Given list_uncovered is "branch"
    And the following branches are missing coverage:
      | File     | Line | Type |
      | file1.rb | 82   | else |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      1 branch is not covered by tests:
        ./file1.rb:82 (else branch)
      """

  Scenario: Output the uncovered methods report
    Given list_uncovered is "method"
    And the following methods are missing coverage:
      | File     | Line | Method  |
      | file1.rb | 90   | Foo#bar |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      1 method is not covered by tests:
        ./file1.rb:90 Foo#bar
      """

  Scenario: Output reports for all criteria, in a fixed line/branch/method order
    Given list_uncovered is "all"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    And the following branches are missing coverage:
      | File     | Line | Type |
      | file1.rb | 82   | else |
    And the following methods are missing coverage:
      | File     | Line | Method  |
      | file1.rb | 90   | Foo#bar |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      1 line is not covered by tests:
        ./file1.rb:1

      1 branch is not covered by tests:
        ./file1.rb:82 (else branch)

      1 method is not covered by tests:
        ./file1.rb:90 Foo#bar
      """

  Scenario: The report was requested but nothing was uncovered
    Given list_uncovered is "all"
    And nothing is missing coverage
    When the at_exit_hook is called
    Then stderr output should NOT include:
      """
      is not covered by tests
      """

  Scenario: There were uncovered lines but the report was not requested
    Given list_uncovered is false
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should NOT include:
      """
      is not covered by tests
      """
