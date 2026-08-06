Feature: Scope the uncovered report to specific files

  Scenario: Reporting on every file (the default)
    Given list_uncovered is "all"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file2.rb | 2    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      2 lines are not covered by tests:
        ./file1.rb:1
        ./file2.rb:2
      """
    And stderr output should NOT include:
      """
      Reporting uncovered
      """
    And stderr output should NOT include:
      """
      Scoped line coverage
      """

  Scenario: Reporting on one file
    Given list_uncovered is "all" and list_uncovered_files is "file1.rb"
    And the following items are covered:
      | File     | Lines | Branches | Methods |
      | file1.rb | 9     | 3        | 2       |
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file2.rb | 2    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines, branches and methods for 1 of 2 files --

      Scoped line coverage: 9 / 10 (90.00%)
      1 line is not covered by tests:
        ./file1.rb:1

      Scoped branch coverage: 3 / 3 (100.00%)
      Scoped method coverage: 2 / 2 (100.00%)
      """
    And stderr output should NOT include:
      """
        ./file2.rb:2
      """

  Scenario: A percentage is truncated, the way SimpleCov truncates its own
    Given list_uncovered is "line" and list_uncovered_files is "file1.rb"
    And the following items are covered:
      | File     | Lines | Branches | Methods |
      | file1.rb | 11    | 0        | 0       |
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      Scoped line coverage: 11 / 12 (91.66%)
      """

  Scenario: A criterion with nothing to cover reports 100%, like SimpleCov does
    Given list_uncovered is "branch" and list_uncovered_files is "file1.rb"
    And the following files are fully covered:
      | File     |
      | file1.rb |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered branches for 1 of 1 file --

      Scoped branch coverage: 0 / 0 (100.00%)

      No uncovered branches in this file.
      """

  Scenario: Summary report scoped to one file
    Given list_uncovered is "all" and list_uncovered_files is "file1.rb" and list_uncovered_detail is false
    And the following items are covered:
      | File     | Lines | Branches | Methods |
      | file1.rb | 8     | 4        | 0       |
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file1.rb | 2    |
      | file2.rb | 3    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines, branches and methods for 1 of 2 files --

      Scoped line coverage: 8 / 10 (80.00%)
      2 lines are not covered by tests.

      Scoped branch coverage: 4 / 4 (100.00%)
      Scoped method coverage: 0 / 0 (100.00%)

      Run with LIST_UNCOVERED_DETAIL=true to see the uncovered lines.
      """
    And stderr output should NOT include:
      """
        ./file1.rb:1
      """

  Scenario: The scoped files are fully covered
    Given list_uncovered is "line" and list_uncovered_files is "file1.rb"
    And the following items are covered:
      | File     | Lines | Branches | Methods |
      | file1.rb | 12    | 0        | 0       |
    And the following lines are missing coverage:
      | File     | Line |
      | file2.rb | 2    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines for 1 of 2 files --

      Scoped line coverage: 12 / 12 (100.00%)

      No uncovered lines in this file.
      """

  Scenario: Nothing in the result matches the scope
    Given list_uncovered is "all" and list_uncovered_files is "no_such_file.rb"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines, branches and methods for 0 of 1 file --

      No files matched, so no coverage was reported.
      """
    And stderr output should NOT include:
      """
      Scoped line coverage
      """

  Scenario: The scope matched a file that SimpleCov never saw
    Given list_uncovered is "all" and list_uncovered_files is a file that exists but was not loaded
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines, branches and methods for 0 of 1 file --

      1 file matched, but it is not in the coverage result. It may not have been loaded by this run, or may be excluded by a SimpleCov filter.
      """
    And stderr output should NOT include:
      """
      No files matched
      """

  Scenario: The scope matched several files that SimpleCov never saw
    Given list_uncovered is "line" and list_uncovered_files is two files that exist but were not loaded
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines for 0 of 1 file --

      2 files matched, but none are in the coverage result. They may not have been loaded by this run, or may be excluded by a SimpleCov filter.
      """

  Scenario: The scope named no files at all
    Given list_uncovered is "line" and list_uncovered_files resolves to no files at all
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines for 0 of 1 file --

      No files were requested, so no coverage was reported.
      """

  Scenario: Scoping to several files
    Given list_uncovered is "line" and list_uncovered_files is "file1.rb" and "file3.rb"
    And the following items are covered:
      | File     | Lines | Branches | Methods |
      | file1.rb | 4     | 0        | 0       |
      | file3.rb | 6     | 0        | 0       |
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file2.rb | 2    |
      | file3.rb | 3    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines for 2 of 3 files --

      Scoped line coverage: 10 / 12 (83.33%)
      2 lines are not covered by tests:
        ./file1.rb:1
        ./file3.rb:3
      """

  Scenario: Scoping with a callable, resolved after the run
    Given list_uncovered is "line" and list_uncovered_files is a callable returning "file1.rb"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file2.rb | 2    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines for 1 of 2 files --

      Scoped line coverage: 0 / 1 (0.00%)
      1 line is not covered by tests:
        ./file1.rb:1
      """

  Scenario: Scoping from the LIST_UNCOVERED_FILES environment variable
    Given list_uncovered is "line" and the LIST_UNCOVERED_FILES environment variable is "file2.rb"
    And the following lines are missing coverage:
      | File     | Line |
      | file1.rb | 1    |
      | file2.rb | 2    |
    When the at_exit_hook is called
    Then stderr output should include:
      """
      -- Reporting uncovered lines for 1 of 2 files --

      Scoped line coverage: 0 / 1 (0.00%)
      1 line is not covered by tests:
        ./file2.rb:2
      """
