# frozen_string_literal: true

require 'simplecov'
require_relative 'simplecov-rspec/described_source_files'
require_relative 'simplecov-rspec/list_uncovered_files_option'
require_relative 'simplecov-rspec/list_uncovered_option'
require_relative 'simplecov-rspec/uncovered_report'

# SimpleCov namespace
module SimpleCov
  # Configure SimpleCov to enforce coverage thresholds for RSpec, on top of what
  # SimpleCov itself already provides.
  #
  # SimpleCov (>= 1.0) can already enforce `minimum_coverage` for line, branch, and
  # method coverage, and will exit with a non-zero status when a threshold is missed.
  # This gem layers four things SimpleCov doesn't do on its own:
  #
  # 1. Suppresses coverage failures when RSpec is run in dry-run mode (e.g. from an IDE).
  # 2. Lists (or summarizes) the individual uncovered lines, branches, and methods.
  # 3. Scopes that listing to the files you name, or to the code the run described.
  # 4. Lets all of the above be overridden from the environment, for CI.
  #
  # Simply add the line `SimpleCov::RSpec.start` in place of `SimpleCov.start` in
  # the project's `spec_helper.rb`. This line must appear before the project is
  # required.
  #
  # @example Initialize SimpleCov with defaults (100% line coverage required)
  #   SimpleCov::RSpec.start
  #
  # @example Require 100% line coverage and 90% branch coverage
  #   SimpleCov::RSpec.start(minimum_coverage: { line: 100, branch: 90 })
  #
  # @example List every uncovered line, branch, and method when coverage is incomplete
  #   SimpleCov::RSpec.start(minimum_coverage: { line: 100, branch: 90 }, list_uncovered: :all)
  #
  # @example Report only counts, with a hint on how to see the details
  #   SimpleCov::RSpec.start(list_uncovered: :all, list_uncovered_detail: false)
  #
  # @example Scope the listing to the code the run described
  #   SimpleCov::RSpec.start(list_uncovered: :all, list_uncovered_files: :described)
  #
  # @example Pass a configuration block to SimpleCov.start
  #   SimpleCov::RSpec.start { formatter SimpleCov::Formatter::LcovFormatter }
  #
  # @api public
  #
  class RSpec
    # @!attribute [r] env
    #   The environment variables consulted for overrides
    #   @return [Hash]
    #   @api private
    #
    # @!attribute [r] simplecov_module
    #   The SimpleCov module being configured
    #   @return [Module]
    #   @api private
    #
    # @!attribute [r] start_config_block
    #   A configuration block passed through to `SimpleCov.start`
    #   @return [Proc, nil]
    #   @api private
    #

    # Configure and start SimpleCov for RSpec
    #
    # @example Initialize SimpleCov with defaults
    #   SimpleCov::RSpec.start
    #
    # @return [Void]
    #
    # @api public
    #
    # @overload start(minimum_coverage: { line: 100 }, fail_on_low_coverage: true, list_uncovered: false, list_uncovered_detail: true, rspec_dry_run: ::RSpec.configuration.dry_run?, env: ENV, &start_config_block) # rubocop:disable Layout/LineLength
    #
    #   @param minimum_coverage [Integer, Hash] the minimum coverage threshold (default: `{ line: 100 }`)
    #
    #     An Integer sets the line coverage threshold. A Hash sets a threshold per
    #     criterion, e.g. `{ line: 100, branch: 90, method: 100 }`. Passed straight
    #     through to `SimpleCov.minimum_coverage`; any criterion given here is
    #     automatically enabled via `SimpleCov.enable_coverage`.
    #
    #   @param fail_on_low_coverage [Boolean] whether to fail if coverage is below the threshold (default: true)
    #
    #     When `false` (or when RSpec is in dry-run mode), `SimpleCov.minimum_coverage`
    #     is never set, so SimpleCov will not fail the build regardless of coverage.
    #
    #     Read from the `FAIL_ON_LOW_COVERAGE` environment variable if set: `true`,
    #     `yes`, `on`, or `1` (case-insensitive) enables it; anything else disables it.
    #
    #   @param list_uncovered [false, :all, Symbol, Array<Symbol>] which coverage criteria to
    #     list uncovered items for (default: false)
    #
    #     `false` reports nothing. `:all` reports line, branch, and method. A Symbol or
    #     Array of Symbols (`:line`, `:branch`, `:method`) reports just those criteria,
    #     independent of what `minimum_coverage` enforces.
    #
    #     Read from the `LIST_UNCOVERED` environment variable if set: `all`, `true`,
    #     `yes`, `on`, or `1` means every criterion; `false`, `no`, `off`, or `0` means
    #     none; otherwise a comma-separated list of criteria, e.g. `line,branch`.
    #
    #   @param list_uncovered_detail [Boolean] list individual items, or just a count (default: true)
    #
    #     When `false`, only the count of uncovered items per criterion is printed,
    #     followed by a hint on how to see the details.
    #
    #     Read from the `LIST_UNCOVERED_DETAIL` environment variable if set: `true`,
    #     `yes`, `on`, or `1` (case-insensitive) shows details; anything else summarizes.
    #
    #   @param list_uncovered_files [nil, Symbol, String, Array<String>, #call] which files to
    #     list uncovered items for (default: nil)
    #
    #     `nil` reports on every file in the result. A String or Array of Strings names
    #     the files to report on, as `Dir.glob` patterns resolved against `SimpleCov.root`.
    #     `:described` reports on the files defining the classes the run described, which
    #     is the scope a focused run usually wants. A callable returning a String or an
    #     Array of Strings is resolved after the run rather than at `start`, which is what
    #     any scope derived from the run needs: `start` runs before any example is defined.
    #
    #     This narrows only the uncovered listing. Coverage is still measured, enforced,
    #     and formatted for the whole project, so the percentage and the HTML report mean
    #     the same thing whether or not this is set.
    #
    #     A scoped report names how many of the result's files it covered, and says so
    #     explicitly when they are fully covered or when nothing matched.
    #
    #     Read from the `LIST_UNCOVERED_FILES` environment variable if set: a
    #     comma-separated list of patterns, `described`, or `all` (or `false`, `no`,
    #     `off`, `0`, or empty) for every file.
    #
    #   @param start_config_block [Proc] a configuration block to pass to `SimpleCov.start` (default: nil)
    #
    #   @param rspec_dry_run [Boolean] whether the rspec run is a dry run
    #
    #     Typically not set by the user. If RSpec is being run in dry run mode, test
    #     coverage under the threshold will not fail the build. This allows test
    #     coverage to be run in a dry run by an IDE so it can report failed tests and
    #     coverage without reporting that the entire RSpec run has failed.
    #
    #   @param simplecov_module [Module] the SimpleCov module (default: ::SimpleCov)
    #
    #     Typically not set by the user. Used for this gem's unit testing.
    #
    #   @param env [Hash] the environment variables (default: ENV)
    #
    #     Typically not set by the user. Used for this gem's unit testing.
    #
    #   @example Initialize SimpleCov with a test coverage threshold other than 100%
    #     SimpleCov::RSpec.start(minimum_coverage: 90)
    #
    #   @example Initialize SimpleCov to not fail the test run if the coverage is below the threshold
    #     SimpleCov::RSpec.start(fail_on_low_coverage: false)
    #
    #     # OR use an environment variable to override the default
    #     FAIL_ON_LOW_COVERAGE=true rspec
    #
    #   @example Initialize SimpleCov to list the lines, branches, and methods not covered by tests
    #     SimpleCov::RSpec.start(list_uncovered: :all)
    #
    #     # OR use an environment variable to override the default
    #     LIST_UNCOVERED=all rspec
    #
    #   @example List uncovered items for one file only
    #     SimpleCov::RSpec.start(list_uncovered: :all, list_uncovered_files: 'lib/example_project/parser.rb')
    #
    #     # OR use an environment variable to override the default
    #     LIST_UNCOVERED_FILES=lib/example_project/parser.rb rspec
    #
    #   @example Scope the listing to the classes the run actually described
    #     SimpleCov::RSpec.start(list_uncovered: :all, list_uncovered_files: :described)
    #
    #     # OR use an environment variable to override the default
    #     LIST_UNCOVERED_FILES=described rspec
    #
    def self.start(...) = new(...).send(:start)

    # The source files defining the classes this RSpec run described
    #
    # What `list_uncovered_files: :described` scopes to. Call it directly to build a
    # scope of your own — to add files the run touches but does not describe, say:
    #
    #     list_uncovered_files: -> { SimpleCov::RSpec.described_source_files + ['lib/support.rb'] }
    #
    # Only meaningful once the run has defined its examples, which is why it is passed
    # as a callable rather than called at `start`.
    #
    # A described class contributes nothing when it is anonymous, defined in C, or no
    # longer reachable by name, since there is no source file to report on.
    #
    # @example Scope the listing to the code under test, plus one more file
    #   SimpleCov::RSpec.start(
    #     list_uncovered: :all,
    #     list_uncovered_files: -> { SimpleCov::RSpec.described_source_files + ['lib/support.rb'] }
    #   )
    #
    # @return [Array<String>] absolute paths, without duplicates
    #
    # @api public
    #
    def self.described_source_files = DescribedSourceFiles.call

    # Environment variable to override minimum_coverage[:line]
    # @api private
    # @private
    COVERAGE_THRESHOLD = 'COVERAGE_THRESHOLD'

    # Environment variable to override minimum_coverage[:branch]
    # @api private
    # @private
    COVERAGE_THRESHOLD_BRANCH = 'COVERAGE_THRESHOLD_BRANCH'

    # Environment variable to override minimum_coverage[:method]
    # @api private
    # @private
    COVERAGE_THRESHOLD_METHOD = 'COVERAGE_THRESHOLD_METHOD'

    # Environment variable to override fail_on_low_coverage
    # @api private
    # @private
    FAIL_ON_LOW_COVERAGE = 'FAIL_ON_LOW_COVERAGE'

    # Environment variable to override list_uncovered
    # @api private
    # @private
    LIST_UNCOVERED = 'LIST_UNCOVERED'

    # Environment variable to override list_uncovered_detail
    # @api private
    # @private
    LIST_UNCOVERED_DETAIL = 'LIST_UNCOVERED_DETAIL'

    # Environment variable to override list_uncovered_files
    # @api private
    # @private
    LIST_UNCOVERED_FILES = 'LIST_UNCOVERED_FILES'

    # Maps a coverage criterion to the environment variable that overrides its threshold
    # @api private
    # @private
    CRITERION_ENV_VARS = {
      line: COVERAGE_THRESHOLD,
      branch: COVERAGE_THRESHOLD_BRANCH,
      method: COVERAGE_THRESHOLD_METHOD
    }.freeze

    # Default value for minimum_coverage
    # @api private
    # @private
    DEFAULT_MINIMUM_COVERAGE = { line: 100 }.freeze

    # Default value for fail_on_low_coverage
    # @api private
    # @private
    DEFAULT_FAIL_ON_LOW_COVERAGE = true

    # Default value for list_uncovered_detail
    # @api private
    # @private
    DEFAULT_LIST_UNCOVERED_DETAIL = true

    # Environment variable values that mean "true"
    # @api private
    # @private
    TRUTHY_ENV_VALUES = %w[yes on true 1].freeze

    attr_reader :env, :simplecov_module, :start_config_block

    # The minimum coverage threshold, per criterion
    #
    # Searches the ENV, the value given in the `.start` method, and the default value,
    # merging them (ENV takes precedence per-criterion).
    #
    # @return [Hash{Symbol => Integer}]
    #
    # @api private
    # @private
    #
    def minimum_coverage
      base = @minimum_coverage
      base = { line: base } if base.is_a?(Integer)
      validate_minimum_coverage!(base)

      (base || DEFAULT_MINIMUM_COVERAGE).merge(env_minimum_coverage_overrides)
    end

    # Whether to fail if the coverage is below the threshold
    #
    # Searches the ENV, the value given in the `.start` method, and the default value
    # and returns the first value found.
    #
    # @return [Boolean]
    #
    # @api private
    # @private
    #
    def fail_on_low_coverage?
      return false if rspec_dry_run?
      return env_true?(FAIL_ON_LOW_COVERAGE) if env.key?(FAIL_ON_LOW_COVERAGE)
      return @fail_on_low_coverage unless @fail_on_low_coverage.nil?

      DEFAULT_FAIL_ON_LOW_COVERAGE
    end

    # The coverage criteria to list uncovered items for
    #
    # Searches the ENV and the value given in the `.start` method, and normalizes
    # the result to an Array of Symbols in a fixed (line, branch, method) order.
    #
    # @return [Array<Symbol>]
    #
    # @api private
    # @private
    #
    def list_uncovered_criteria
      @list_uncovered_criteria ||= ListUncoveredOption.resolve(@list_uncovered, env: env, env_var: LIST_UNCOVERED)
    end

    # The files to list uncovered items for, or nil for every file in the result
    #
    # Resolved from the `at_exit` hook rather than at `start`: `start` runs before any
    # example is defined, so a caller scoping the report to the code under test cannot
    # know which files those are until the run is over.
    #
    # @return [Array<String>, nil]
    #
    # @api private
    # @private
    #
    def list_uncovered_files
      ListUncoveredFilesOption.resolve(
        @list_uncovered_files, env: env, env_var: LIST_UNCOVERED_FILES, root: simplecov_module.root
      )
    end

    # Whether to list individual uncovered items, or just a count per criterion
    #
    # @return [Boolean]
    #
    # @api private
    # @private
    #
    def list_uncovered_detail?
      return env_true?(LIST_UNCOVERED_DETAIL) if env.key?(LIST_UNCOVERED_DETAIL)
      return @list_uncovered_detail unless @list_uncovered_detail.nil?

      DEFAULT_LIST_UNCOVERED_DETAIL
    end

    # Whether the rspec run is a dry run
    #
    # @return [Boolean]
    #
    # @api private
    # @private
    #
    def rspec_dry_run? = @rspec_dry_run

    private

    # rubocop:disable Metrics/ParameterLists

    # Create a new SimpleCov::RSpec instance
    # @see SimpleCov::RSpec.start
    # @api private
    # @private
    def initialize(
      minimum_coverage: nil,
      fail_on_low_coverage: nil,
      list_uncovered: nil,
      list_uncovered_detail: nil,
      list_uncovered_files: nil,
      rspec_dry_run: ::RSpec.configuration.dry_run?,
      env: ENV,
      simplecov_module: ::SimpleCov,
      &start_config_block
    )
      @minimum_coverage = minimum_coverage
      @fail_on_low_coverage = fail_on_low_coverage
      @list_uncovered = list_uncovered
      @list_uncovered_detail = list_uncovered_detail
      @list_uncovered_files = list_uncovered_files
      @start_config_block = start_config_block
      @rspec_dry_run = rspec_dry_run
      @env = env
      @simplecov_module = simplecov_module
    end

    # rubocop:enable Metrics/ParameterLists

    # Configure SimpleCov and start it
    # @return [Void]
    # @api private
    # @private
    def start
      simplecov_module.at_exit(&at_exit_hook)
      simplecov_module.enable_coverage(*criteria_to_enable) if criteria_to_enable.any?
      simplecov_module.minimum_coverage(minimum_coverage) if enforce_minimum_coverage?
      simplecov_module.start(&start_config_block)
    end

    # Whether SimpleCov should be configured to enforce minimum_coverage itself
    # @return [Boolean]
    # @api private
    # @private
    def enforce_minimum_coverage? = !rspec_dry_run? && fail_on_low_coverage?

    # The coverage criteria that need to be enabled via SimpleCov.enable_coverage
    # @return [Array<Symbol>]
    # @api private
    # @private
    def criteria_to_enable = (minimum_coverage.keys + list_uncovered_criteria).uniq

    # Called by SimpleCov.at_exit
    # @return [Proc]
    # @api private
    # @private
    def at_exit_hook
      lambda do
        simplecov_module.result.format!
        output_uncovered_report
      end
    end

    # Output the uncovered items report (detailed or summary), if requested
    # @return [Void]
    # @api private
    # @private
    def output_uncovered_report
      return if list_uncovered_criteria.empty?

      report = UncoveredReport.new(
        result: simplecov_module.result, criteria: list_uncovered_criteria, detail: list_uncovered_detail?,
        detail_env_var: LIST_UNCOVERED_DETAIL, files: list_uncovered_files
      ).to_s
      return if report.empty?

      $stderr.puts
      $stderr.puts report
    end

    # Raise unless `base` is a valid `minimum_coverage` value
    #
    # Valid values include `nil`, or a Hash keyed by `:line`, `:branch`, and/or
    # `:method`, with Numeric values
    #
    # @param base [nil, Hash] the normalized `minimum_coverage` value
    # @return [Void]
    # @raise [ArgumentError] if `base` is not nil or a Hash, has an unknown key, or has a
    #   non-Numeric value
    # @api private
    # @private
    def validate_minimum_coverage!(base)
      unless base.nil? || base.is_a?(Hash)
        raise ArgumentError, "minimum_coverage must be nil, an Integer, or a Hash; got #{base.inspect}"
      end

      base&.each_pair { |criterion, threshold| validate_minimum_coverage_entry!(criterion, threshold) }
    end

    # Raise unless `criterion` is a known criterion with a Numeric `threshold`
    # @param criterion [Object] the candidate `minimum_coverage` key
    # @param threshold [Object] the candidate `minimum_coverage` value
    # @return [Void]
    # @raise [ArgumentError] if `criterion` is unknown, or `threshold` is not Numeric
    # @api private
    # @private
    def validate_minimum_coverage_entry!(criterion, threshold)
      unless CRITERION_ENV_VARS.key?(criterion)
        raise ArgumentError,
              "minimum_coverage keys must be #{CRITERION_ENV_VARS.keys.inspect}; got #{criterion.inspect}"
      end

      return if threshold.is_a?(Numeric)

      raise ArgumentError,
            "minimum_coverage[#{criterion.inspect}] must be a Numeric; got #{threshold.inspect}"
    end

    # The per-criterion COVERAGE_THRESHOLD* ENV overrides, as a minimum_coverage Hash
    # @return [Hash{Symbol => Integer}]
    # @api private
    # @private
    def env_minimum_coverage_overrides
      CRITERION_ENV_VARS.each_with_object({}) do |(criterion, var), overrides|
        overrides[criterion] = env.fetch(var).to_i if env.key?(var)
      end
    end

    # Return `true` if the environment variable is set to a truthy value
    #
    # @example
    #   env_true?('LIST_UNCOVERED_DETAIL')
    #
    # @param name [String] the name of the environment variable
    # @return [Boolean]
    # @api private
    # @private
    #
    def env_true?(name) = TRUTHY_ENV_VALUES.include?(env.fetch(name, '').downcase)
  end
end
