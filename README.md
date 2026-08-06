# The `simplecov-rspec` Gem

[![Gem Version](https://badge.fury.io/rb/simplecov-rspec.svg)](https://badge.fury.io/rb/simplecov-rspec)
[![Documentation](https://img.shields.io/badge/Documentation-Latest-green)](https://rubydoc.info/gems/simplecov-rspec/)
[![Change Log](https://img.shields.io/badge/CHANGELOG-Latest-green)](https://rubydoc.info/gems/simplecov-rspec/file/CHANGELOG.md)
[![Build Status](https://github.com/main-branch/simplecov-rspec/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/main-branch/simplecov-rspec/actions/workflows/continuous_integration.yml)
[![Conventional
Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Slack](https://img.shields.io/badge/slack-main--branch/simplecov--rspec-yellow.svg?logo=slack)](https://main-branch.slack.com/archives/C07MCM9J72B)

`simplecov-rspec` is a Ruby gem that integrates SimpleCov with RSpec. SimpleCov
(`>= 1.0`) already enforces `minimum_coverage` for line, branch, and method coverage
and fails the build when a threshold is missed. This gem layers four things on top
that SimpleCov doesn't do on its own:

1. Suppresses coverage failures when RSpec is run in dry-run mode (e.g. from an IDE).
2. Lists (or summarizes) the individual uncovered lines, branches, and methods.
3. Scopes that listing to the files you name.
4. Lets all of the above be overridden from the environment, for CI.

When `simplecov-rspec` is used, RSpec will report an error if the percent of test
coverage falls below a defined threshold:

```text
Coverage report generated for RSpec to coverage/index.html
Line coverage: 284 / 286 (99.30%)
Line coverage (99.30%) is below the expected minimum coverage (100.00%).
  Lowest-coverage files (line):
     99.30%  lib/example_project.rb
SimpleCov failed with exit 2 due to a coverage related error
```

All of that comes from SimpleCov itself. If configured to list the items that were not
covered by tests, this gem adds its own listing between SimpleCov's summary and its
failure message:

```text
Coverage report generated for RSpec to coverage/index.html
Line coverage: 284 / 286 (99.30%)

2 lines are not covered by tests:
  ./lib/example_project.rb:74
  ./lib/example_project.rb:75
Line coverage (99.30%) is below the expected minimum coverage (100.00%).
```

Scoping the listing to particular files changes its shape again. It is marked off with a
header saying how much of the result it covers, and each criterion reports what the
scoped files cover directly above what they miss — see [Scoping the listing to specific
files](#scoping-the-listing-to-specific-files):

```text
Coverage report generated for RSpec to coverage/index.html
Line coverage: 284 / 286 (99.30%)
Branch coverage: 138 / 150 (92.00%)

-- Reporting uncovered lines and branches for 1 of 12 files --

Scoped line coverage: 73 / 74 (98.64%)
1 line is not covered by tests:
  ./lib/example_project/parser.rb:74

Scoped branch coverage: 11 / 12 (91.66%)
1 branch is not covered by tests:
  ./lib/example_project/parser.rb:82 (then branch)
```

- [Installation](#installation)
- [Getting started](#getting-started)
  - [Basic setup](#basic-setup)
  - [Listing uncovered items](#listing-uncovered-items)
  - [Scoping the listing to specific files](#scoping-the-listing-to-specific-files)
  - [Configuration block](#configuration-block)
  - [Configuration from environment variables](#configuration-from-environment-variables)
- [Development](#development)
- [Contributing](#contributing)
  - [Commit message guidelines](#commit-message-guidelines)
  - [Pull request guidelines](#pull-request-guidelines)
- [License](#license)
- [Code of conduct](#code-of-conduct)

## Installation

To install the gem, add to the following line to your application's gemspec OR Gemfile:

gemspec:

```ruby
  spec.add_development_dependency "simplecov-rspec", '~> 1.0'
```

Gemfile:

```ruby
gem "simplecov-rspec", "~> 1.0", groups: [:development, :test]
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
    minimum_coverage: { line: 100 },
    fail_on_low_coverage: true,
    list_uncovered: false,
    list_uncovered_detail: true,
    list_uncovered_files: nil
)
```

`minimum_coverage` is the minimum percent of lines (and, optionally, branches and
methods) covered by tests, enforced by SimpleCov itself.

To require less than 100% line coverage:

```ruby
SimpleCov::RSpec.start(minimum_coverage: 90)
```

To also require branch (and/or method) coverage, pass a Hash. Any criterion named
here is automatically enabled via `SimpleCov.enable_coverage`:

```ruby
SimpleCov::RSpec.start(minimum_coverage: { line: 100, branch: 90 })
```

### Listing uncovered items

To list the individual lines, branches, and/or methods that are not covered, set
`list_uncovered`. It accepts `:all`, a single criterion, or an Array of criteria —
independent of what `minimum_coverage` enforces:

```ruby
SimpleCov::RSpec.start(minimum_coverage: { line: 100, branch: 90 }, list_uncovered: :all)
```

```text
2 lines are not covered by tests:
  ./lib/example_project.rb:74
  ./lib/example_project.rb:75

1 branch is not covered by tests:
  ./lib/example_project.rb:82 (else branch)

1 method is not covered by tests:
  ./lib/example_project.rb:96 ExampleProject#unused
```

A criterion with nothing uncovered is left out entirely, so `:all` prints fewer sections
than this when there is less to say.

For a quieter CI log, set `list_uncovered_detail: false` to print only the count per
criterion, along with a hint on how to see the details:

```ruby
SimpleCov::RSpec.start(list_uncovered: :all, list_uncovered_detail: false)
```

```text
2 lines are not covered by tests.
1 branch is not covered by tests.
1 method is not covered by tests.

Run with LIST_UNCOVERED_DETAIL=true to see the uncovered lines, branches and methods.
```

### Scoping the listing to specific files

By default the uncovered listing covers every file SimpleCov tracked. On a focused run
— one spec file, or one directory — that listing is mostly noise: `spec_helper`
requires the whole project, so nearly all of it is legitimately unexercised.

`list_uncovered_files` (available since version 1.1) narrows the listing to the files
you care about, given as `Dir.glob` patterns resolved against `SimpleCov.root`. An
absolute path is used as given:

```ruby
SimpleCov::RSpec.start(list_uncovered: :all, list_uncovered_files: 'lib/example_project/parser.rb')
```

This option scopes the listing that `list_uncovered` asks for; it does not ask for one.
`list_uncovered` defaults to `false`, which lists nothing, so setting only
`list_uncovered_files` produces no output at all. Set both.

```text
-- Reporting uncovered lines, branches and methods for 1 of 218 files --

Scoped line coverage: 73 / 74 (98.64%)
1 line is not covered by tests:
  ./lib/example_project/parser.rb:74

Scoped branch coverage: 12 / 12 (100.00%)
Scoped method coverage: 8 / 8 (100.00%)
```

Each criterion reports what the scoped files cover directly above what they miss, so a
count like "1 line is not covered" arrives with the denominator that makes it readable,
and a blank line always means "next criterion". These are deliberately labelled
differently from SimpleCov's own project-wide summary, and the report is marked off with
a header, because SimpleCov prints that summary a few lines earlier on the same stream
while counting different things.

This narrows **only the listing**. Coverage is still measured, enforced, and formatted
for the whole project, so the reported percentage and the HTML report mean the same
thing whether or not this option is set. There is one definition of "the coverage
number", and this option does not change it.

A scoped report always prints something, and always says how much of the result it
covered, so it can never be mistaken for a clean run of the whole suite:

```text
-- Reporting uncovered lines, branches and methods for 1 of 218 files --

Scoped line coverage: 74 / 74 (100.00%)
Scoped branch coverage: 12 / 12 (100.00%)
Scoped method coverage: 8 / 8 (100.00%)

No uncovered lines, branches and methods in this file.
```

When it comes up empty, it says which of the three reasons applies, since only one of
them means you mistyped a pattern:

```text
-- Reporting uncovered lines, branches and methods for 0 of 218 files --

No files matched, so no coverage was reported.
```

```text
-- Reporting uncovered lines, branches and methods for 0 of 218 files --

1 file matched, but it is not in the coverage result. It may not have been loaded by
this run, or may be excluded by a SimpleCov filter.
```

```text
-- Reporting uncovered lines, branches and methods for 0 of 218 files --

No files were requested, so no coverage was reported.
```

### Configuration block

A configuration block can be given to the `start` method to further configure
SimpleCov:

```ruby
# Initialize SimpleCov with a specific formatter
SimpleCov::RSpec.start { formatter SimpleCov::Formatter::LcovFormatter }
```

This block is passed on to `SimpleCov.start`. See [Configuring
SimpleCov](https://github.com/simplecov-ruby/simplecov?tab=readme-ov-file#configuration)
for details.

### Configuration from environment variables

Environment variables can be used to configure `simplecov-rspec`. These environment
variables take precedence over the values passed to `SimpleCov::RSpec.start`.

* **`COVERAGE_THRESHOLD`**: Sets the minimum line coverage threshold (0-100). Overrides
  `minimum_coverage[:line]`.
* **`COVERAGE_THRESHOLD_BRANCH`**: Sets the minimum branch coverage threshold (0-100), and
  enables branch coverage. Overrides `minimum_coverage[:branch]`.
* **`COVERAGE_THRESHOLD_METHOD`**: Sets the minimum method coverage threshold (0-100), and
  enables method coverage. Overrides `minimum_coverage[:method]`.
* **`FAIL_ON_LOW_COVERAGE`**: Controls whether tests fail if coverage is below the threshold.
  Set to 'true', 'yes', 'on', or '1' (case insensitive) to enable.
* **`LIST_UNCOVERED`**: Controls which criteria to list uncovered items for. Set to 'all',
  'true', 'yes', 'on', or '1' to report every criterion; 'false', 'no', 'off', or '0' to
  report none; or a comma-separated list, e.g. `line,branch`.
* **`LIST_UNCOVERED_DETAIL`**: Controls whether uncovered items are listed individually, or
  just summarized as a count per criterion. Set to 'true', 'yes', 'on', or '1' (case
  insensitive) to show individual items.
* **`LIST_UNCOVERED_FILES`**: Controls which files uncovered items are listed for. Set to a
  comma-separated list of `Dir.glob` patterns, relative to `SimpleCov.root`; or to 'all'
  (or 'false', 'no', 'off', '0', or empty) to list them for every file. Since the
  separator is a comma, a brace pattern such as `lib/{a,b}.rb` cannot be used here —
  give the alternatives separately, as `lib/a.rb,lib/b.rb`. Like `list_uncovered_files`,
  this scopes the listing rather than asking for one: it has no effect unless
  `LIST_UNCOVERED` (or `list_uncovered:`) names at least one criterion.

For example, here is a bash script to run tests in an infinite loop while writing
test output to `fail.txt`:

```bash
while true; do FAIL_ON_LOW_COVERAGE=false rspec >> fail.txt; done
```

In a CI system, you might want to set `LIST_UNCOVERED=all` in order to list uncovered
lines, branches, and methods on a platform other than the one you use for local
development.

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
