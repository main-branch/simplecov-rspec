# Change Log

Changes for each release are listed in this file.

This project adheres to [Semantic Versioning](https://semver.org/) for its releases.

## [1.1.0](https://github.com/main-branch/simplecov-rspec/compare/v1.0.0...v1.1.0) (2026-08-06)


### Features

* Add :described to scope the listing to the code under test ([71fe0c7](https://github.com/main-branch/simplecov-rspec/commit/71fe0c715063582ff207a6ac15e9a2c6dbe26243))
* Add list_uncovered_files to scope the uncovered listing ([1981e65](https://github.com/main-branch/simplecov-rspec/commit/1981e6528a418340c4e211ff0b34ed745693151a))

## [1.0.0](https://github.com/main-branch/simplecov-rspec/compare/v0.4.4...v1.0.0) (2026-08-05)


### ⚠ BREAKING CHANGES

* `coverage_threshold:` and `list_uncovered_lines:` are removed in favor of `minimum_coverage:` and `list_uncovered:`; the `LIST_UNCOVERED_LINES` env var is removed in favor of `LIST_UNCOVERED`; and `COVERAGE_THRESHOLD` now sets only the line-coverage threshold instead of an overall coverage percentage. Update calls to `SimpleCov::RSpec.start` and any CI environment variables accordingly.
* drops support for Ruby 3.1 and JRuby 9.4; the minimum is now Ruby 3.2 (or JRuby 10, which reports RUBY_VERSION 3.4).

### Features

* Rely on SimpleCov's own minimum_coverage instead of reimplementing it ([d2fed78](https://github.com/main-branch/simplecov-rspec/commit/d2fed78ff5e5cb2bbf18bc89cb3b301455de0bce))
* Require Ruby &gt;= 3.2, matching SimpleCov 1.0's own floor ([9452587](https://github.com/main-branch/simplecov-rspec/commit/9452587137e1b698019d4214981f82ed796b9c1d))

## [0.4.4](https://github.com/main-branch/simplecov-rspec/compare/v0.4.3...v0.4.4) (2026-04-24)


### Other Changes

* **dependencies:** Update dependencies for all GitHub Actions workflows ([8e0f4a7](https://github.com/main-branch/simplecov-rspec/commit/8e0f4a7501ba6933d963616ceb122247380fb8ea))

## [0.4.3](https://github.com/main-branch/simplecov-rspec/compare/v0.4.2...v0.4.3) (2025-04-18)


### Other Changes

* Configure release-please to includes all changes in the CHANGELOG ([8efc084](https://github.com/main-branch/simplecov-rspec/commit/8efc0843a8c25a1da07ac5f521a3a17808de9be5))

## [0.4.2](https://github.com/main-branch/simplecov-rspec/compare/v0.4.1...v0.4.2) (2025-04-17)


### Bug Fixes

* Do not trigger build workflows after merging to main or for release PRs ([6ff9a4c](https://github.com/main-branch/simplecov-rspec/commit/6ff9a4ca3cff10079f04e2dab4c6191e27dfa860))

## [0.4.1](https://github.com/main-branch/simplecov-rspec/compare/v0.4.0...v0.4.1) (2025-04-16)


### Bug Fixes

* Automate commit-to-publish workflow ([9594c8e](https://github.com/main-branch/simplecov-rspec/commit/9594c8e1c838e33abc16f844fd0ab4c445c94965))

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
