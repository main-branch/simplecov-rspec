# Change Log

Changes for each release are listed in this file.

This project adheres to [Semantic Versioning](https://semver.org/) for its releases.

## v0.4.0 (2024-10-10)

[Full Changelog](https://github.com/main-branch/simplecov-rspec/compare/v0.3.2..v0.4.0)

Changes since v0.3.2:

* e06d866 build: update create_github_release dependency
* b8aafa3 docs: add conventional commit badge to README
* 596b217 build: remove semver pr label check
* bed5192 build: enforce conventional commit message formatting
* d036188 Clarify gem installation and configuration via env variables
* 1d89785 Add TargetRubyVersion in .rubocop.yml
* 2017a2f Use shared Rubocop config

## v0.3.2 (2024-09-17)

[Full Changelog](https://github.com/main-branch/simplecov-rspec/compare/v0.3.1..v0.3.2)

Changes since v0.3.1:

* 7da8291 Update links in gemspec
* c050356 Add Slack badge for this project in README
* b9e3dfb Release v0.3.1

## v0.3.1 (2024-09-16)

[Full Changelog](https://github.com/main-branch/simplecov-rspec/compare/v0.3.0..v0.3.1)

Changes since v0.3.0:

* 1fca720 Remove unneeded --exclude options in .yardopts
* e60794d Update yardopts with new standard options
* 31537ec Fix the YARD doc generation to use the correct license file name
* aebb048 Standardize YARD and Markdown Lint configurations
* 474adfb Update CODEOWNERS file
* ca1aca3 Document why the JRuby --debug flag is being set
* 8e0ad31 Set JRuby —debug option when running tests in GitHub Actions workflows
* fa10ba3 Fix example of uncovered lines listing in README

## v0.3.0 (2024-09-14)

[Full Changelog](https://github.com/main-branch/simplecov-rspec/compare/v0.2.1..v0.3.0)

Changes since v0.2.1:

* 55c3812 Output the number of lines missing coverage
* 9356f64 Rename variables from "lines_not_covered" to "uncovered_lines" to be consistent
* ec637c0 Fix error in README
* 9d9cb0c Rearrange workflow definitions to have the name first
* ac8efae Update continuous integration and experimental ruby builds
* ac1da92 Use v1 tag for the semver_pr_label_check workflow
* d701393 Auto-correct new Rubocop offenses
* 0319f68 Update minimal Ruby version to 3.1
* d6b57d1 Update code climate test coverage reporter version to v9
* 02553a1 Change simplecov from a development dependency to a runtime dependency

## v0.2.1 (2024-09-10)

[Full Changelog](https://github.com/main-branch/simplecov-rspec/compare/v0.2.0..v0.2.1)

Changes since v0.2.0:

* d714b58 Simplify how the experimental ruby builds are triggered
* de79d66 Use a reusable workflow for the Semver PR label check
* d29ecac Add Semver PR Label workflow
* 0fed875 Update the version of code climate test coverage reporter

## v0.2.0 (2024-09-08)

[Full Changelog](https://github.com/main-branch/simplecov-rspec/compare/v0.1.0..v0.2.0)

Changes since v0.1.0:

* 2b544ee Allow the CI build to be manually triggered
* 50e1b4a Rename lib/simplecov/rspec to lib/simplecov-rspec (and related files)
* 0884d23 Move CI build using Ruby head to an different workflow

## v0.1.0 (2024-09-07)

[Full Changelog](https://github.com/main-branch/simplecov-rspec/compare/9fe828c..v0.1.0)

Changes:

* 93d7004 Add RSpec HTML formatter for CI build
* 94f5a80 Configure RSpec to run turnip tests when run from rake
* b3bf845 Use SimpleCov LCov formatter in the CI build
* 9fe828c Initial revision
