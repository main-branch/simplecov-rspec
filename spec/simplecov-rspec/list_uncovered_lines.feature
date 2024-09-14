Feature: List uncovered lines
  Scenario: Output the uncovered lines report (for a single lines)
    Given the code coverage is below the threshold
    And list_uncovered_lines? is true
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
    Given the code coverage is below the threshold
    And list_uncovered_lines? is true
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

  Scenario: When the uncovered lines report was requested but there were no uncovered lines
    Given the code coverage is below the threshold
    And list_uncovered_lines? is true
    And no lines are missing coverage
    When the at_exit_hook is called
    Then stderr output should NOT include:
      """
      lines were not covered by tests:
      """

  Scenario: There were uncovered lines but the uncovered lines report was not requested
    Given the code coverage is below the threshold
    And list_uncovered_lines? is false
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file1.rb | 2    |
    When the at_exit_hook is called
    Then stderr output should NOT include:
      """
      lines were not covered by tests:
      """
