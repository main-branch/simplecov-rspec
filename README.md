# The `simplecov-rspec` Gem

[![Gem Version](https://badge.fury.io/rb/simplecov-rspec.svg)](https://badge.fury.io/rb/simplecov-rspec)
[![Documentation](https://img.shields.io/badge/Documentation-Latest-green)](https://rubydoc.info/gems/simplecov-rspec/)
[![Change Log](https://img.shields.io/badge/CHANGELOG-Latest-green)](https://rubydoc.info/gems/simplecov-rspec/file/CHANGELOG.md)
[![Build Status](https://github.com/main-branch/simplecov-rspec/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/main-branch/simplecov-rspec/actions/workflows/continuous_integration.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/9a58b51d18910db724c7/maintainability)](https://codeclimate.com/github/main-branch/simplecov-rspec/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/9a58b51d18910db724c7/test_coverage)](https://codeclimate.com/github/main-branch/simplecov-rspec/test_coverage)
[![Slack](https://img.shields.io/badge/slack-main--branch/simplecov--rspec-yellow.svg?logo=slack)](https://main-branch.slack.com/archives/C07MCM9J72B)

`simplecov-rspec` is a Ruby gem that integrates SimpleCov with RSpec to ensure your
tests meet a minimum coverage threshold. It enhances your test suite by automatically
failing tests when coverage falls below a specified threshold and, optionally,
listing uncovered lines to help you improve coverage.

When `simplecov-rspec` is used, RSpec will report an error if the percent of test
coverage falls below a defined threshold:

```text
Coverage report generated for RSpec to /Projects/example_project/coverage. 284 / 286 LOC (99.3%) covered.

FAIL: RSpec Test coverage fell below 100%
```

If configured to list the lines that were not covered by tests, RSpec will additionally output:

```text
2 lines are not covered by tests:
  ./lib/example_project.rb:74
  ./lib/example_project.rb:75
```

* [Installation](#installation)
* [Getting started](#getting-started)
  * [Basic setup](#basic-setup)
  * [Configuration from environment variables](#configuration-from-environment-variables)
* [Development](#development)
* [Contributing](#contributing)
  * [Commit message guidelines](#commit-message-guidelines)
  * [Pull request guidelines](#pull-request-guidelines)
* [License](#license)
* [Code of conduct](#code-of-conduct)

## Installation

To install the gem, add to the following line to your application's gemspec OR Gemfile:

gemspec:

```ruby
  spec.add_development_dependency "simplecov-rspec", '~> 0.1'
```

Gemfile:

```ruby
gem "simplecov-rspec", "~> 0.1", groups: [:development, :test]
```

and then run `bundle install`

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install simplecov-rspec
```

## Getting started

To use `simplecov-rspec`, follow these steps:

1. Add `require 'simplecov-rspec'` to your `spec_helper.rb`.
2. Replace `SimpleCov.start` with `SimpleCov::RSpec.start` in your `spec_helper.rb`,
   ensuring this line appears before requiring your project files.

Here is an example `spec_helper.rb`. Your spec helper may include
other code in addition to these:

```ruby
require 'simplecov-rspec'

SimpleCov::RSpec.start

require 'my_project'
```

This will configure RSpec to fail when test coverage falls below 100%.

That is it!

### Basic setup

To initialize simplecov-rspec with defaults, add the following to your `spec_helper.rb`:

```ruby
require 'simplecov-rspec'

SimpleCov::RSpec.start
```

This is equivalent to starting with the following options:

```ruby
SimpleCov::RSpec.start(
    coverage_threshold: 100,
    fail_on_low_coverage: true,
    list_uncovered_lines: false
)
```

The test coverage threshold is the minimum percent of lines covered by tests as
tracked by SimpleCov.

To initialize SimpleCov with a test coverage threshold less than 100%:

```ruby
SimpleCov::RSpec.start(coverage_threshold: 90)
```

A configuration block can be given to the `start` method to further configure
SimpleCov:

```ruby
# Initialize SimpleCov with a specific formatter
SimpleCov::RSpec.start { formatter = SimpleCov::Formatter::LcovFormatter }
```

This block is passed on to `SimpleCov::RSpec.start`. See [Configuring
SimpleCov](https://github.com/simplecov-ruby/simplecov?tab=readme-ov-file#configuring-simplecov)
for details.

### Configuration from environment variables

Environment variables can be used to configure `simplecov-rspec`. These environment
variables take presidence over the values passed to `SimpleCov::RSpec.start`.

* **`COVERAGE_THRESHOLD`**: Sets the minimum coverage threshold (0-100). Overrides
  `coverage_threshold`.
* **`FAIL_ON_LOW_COVERAGE`**: Controls whether tests fail if coverage is below the threshold.
  Set to 'true', 'yes', 'on', or '1' (case insensitive) to enable.
* **`LIST_UNCOVERED_LINES`**: Determines if uncovered lines are listed. Set to 'true',
  'yes', 'on', or '1' (case insensitive) to enable.

For example, here is a bash script to run tests in an infinite loop while writing
test output to `fail.txt`:

```bash
while true; do COV_NO_FAIL=TRUE rspec >> fail.txt; done
```

In a CI system, you might want to set `LIST_UNCOVERED_LINES=yes` in order to list
uncovered lines on different platforms than the one you run for local development.

## Development

If you want to contribute or experiment with the gem, follow these steps to set up
your development environment:

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake`
to run linting, tests, etc. just like the CI build. You can also run `bin/console` for an interactive prompt that
will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push git
commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/main-branch/simplecov-rspec. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to the
[code of
conduct](https://github.com/main-branch/simplecov-rspec/blob/main/CODE_OF_CONDUCT.md).

### Commit message guidelines

All commit messages must follow the [Conventional Commits
standard](https://www.conventionalcommits.org/en/v1.0.0/). This helps us maintain a
clear and structured commit history, automate versioning, and generate changelogs
effectively.

To ensure compliance, this project includes:

* A git commit-msg hook that validates your commit messages before they are accepted.

  To activate the hook, you must have node installed and run `npm install`.

* A GitHub Actions workflow that will enforce the Conventional Commit standard as
  part of the continuous integration pipeline.

  Any commit message that does not conform to the Conventional Commits standard will
  cause the workflow to fail and not allow the PR to be merged.

### Pull request guidelines

All pull requests must be merged using rebase merges. This ensures that commit
messages from the feature branch are preserved in the release branch, keeping the
history clean and meaningful.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of conduct

Everyone interacting in the Simplecov::Rspec project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/main-branch/simplecov-rspec/blob/main/CODE_OF_CONDUCT.md).
