# frozen_string_literal: true

require 'simplecov'

# SimpleCov namespace
module SimpleCov
  # Configure SimpleCov to fail RSpec if the test coverage falls below a given threshold
  #
  # Configures RSpec to:
  #
  # 1. Fail (and exit with with a non-zero exitcode) if the test
  #    coverage is below the configured threshold and
  # 2. (optionally) list the lines of code not covered by tests.
  #
  # Simply add the line `SimpleCov::RSpec.start` in place of `SimpleCov::Start` in
  # the project's `spec_helper.rb`. This line must appear before the project is
  # required.
  #
  # @example Initialize SimpleCov with defaults
  #   SimpleCov::RSpec.start
  #
  # @example Initialize SimpleCov with a test coverage threshold other than 100%
  #   SimpleCov::RSpec.start(coverage_threshold: 90, fail_on_low_coverage: true, list_uncovered_lines: false)
  #
  # @example Pass a configuration block to SimpleCov::RSpec.start
  #   SimpleCov::RSpec.start { formatter = SimpleCov::Formatter::LcovFormatter }
  #
  # @example Bash script to run tests in an infinite loop writing failures to `fail.txt`:
  #   while true; do FAIL_ON_LOW_COVERAGE=TRUE rspec >> fail.txt; done
  #
  # @!attribute [r] env
  #   Command line environment variables (default: ENV)
  #   @return [Hash]
  #   @api private
  #   @private
  #
  # @!attribute [r] simplecov_module
  #   The SimpleCov module (default: ::SimpleCov)
  #   @return [Module]
  #   @api private
  #   @private
  #
  # @!attribute [r] start_config_block
  #   A configuration block to pass to `SimpleCov.start`
  #   @return [Proc]
  #   @api private
  #   @private
  #
  # @api public
  #
  class RSpec
    # rubocop:disable Layout/LineLength

    # Configure and start SimpleCov for RSpec
    #
    # @example Initialize SimpleCov with defaults
    #   SimpleCov::RSpec.start
    #
    # @return [Void]
    #
    # @api public
    #
    # @overload start(coverage_threshold: 100, fail_on_low_coverage: true, list_uncovered_lines: false, rspec_dry_run: ::RSpec.configuration.dry_run?, env: ENV, &start_config_block)
    #
    #   @param coverage_threshold [Integer] the test coverage threshold (default: 100)
    #
    #     Coverage below this threshold will cause the rspec to fail if
    #     fail_on_low_coverage is true.
    #
    #   @param fail_on_low_coverage [Boolean] whether to fail if the coverage is below the threshold (default: true)
    #
    #     This setting will be read from the environment variable FAIL_ON_LOW_COVERAGE if
    #     it is NOT given in the `.start` method. Setting that environment variable
    #     to 'true', 'yes', 'on', or '1' will cause this setting to be `false`
    #     (the logic is inverted). Any other value will cause this seetting to
    #     be `true`.
    #
    #   @param list_uncovered_lines [Boolean] whether to list the lines not covered by tests (default: false)
    #
    #     All lines not covered by tests will be listed if the coverage is below the threshold.
    #     Probably only makes sense to use if the threshold is 100%.
    #
    #     This setting will be read from the environment variable LIST_UNCOVERED_LINES
    #     if it is NOT given in the `.start` method. Setting that environment variable
    #     to 'true', 'yes', 'on', or '1' will cause this setting to be `true`. Any
    #     other value will cause this setting to be `false`.
    #
    #   @param start_config_block [Proc] a configuration block to pass to `SimpleCov.start` (default: nil)
    #
    #   @param rspec_dry_run [Boolean] whether the rspec run is a dry run
    #
    #     Typically not set by the user. Used for this gem's unit testing.
    #
    #     If RSpec is being run in dry run mode, test coverage under the threshold will not fail the build.
    #
    #     The purpose of this is to allow the test coverage to be run in a dry run by an IDE
    #     so it can report failed tests and coverage without reporting that the entire RSpec
    #     run has failed.
    #
    #   @param simplecov_module [Module] the SimpleCov module (default: ::SimpleCov)
    #
    #     Typically not set by the user. Used for this gem's unit testing.
    #
    #     Allows the SimpleCov module to be mocked.
    #
    #   @param env [Hash] the environment variables (default: ENV)
    #
    #     Typically not set by the user. Used for this gem's unit testing.
    #
    #   @example Initialize SimpleCov with a test coverage threshold other than 100%
    #     SimpleCov::RSpec.start(coverage_threshold: 90)
    #
    #   @example Initialize SimpleCov to not fail the test run if the coverage is below the threshold
    #     SimpleCov::RSpec.start(fail_on_low_coverage: false)
    #
    #     # OR use an environment variable to override the default
    #     ENV['FAIL_ON_LOW_COVERAGE'] = 'true'
    #     SimpleCov::RSpec.start
    #
    #     # OR use an environment variable to override the default from the rspec command line
    #     FAIL_ON_LOW_COVERAGE=TRUE rspec
    #
    #   @example Initialize SimpleCov to list the lines not covered by tests
    #     SimpleCov::RSpec.start(list_uncovered_lines: true)
    #
    #     # OR use an environment variable to override the default
    #     ENV['LIST_UNCOVERED_LINES'] = 'true'
    #     SimpleCov::RSpec.start
    #
    #     # OR use an environment variable to override the default from the rspec command line
    #     LIST_UNCOVERED_LINES=TRUE rspec
    #
    def self.start(...) = new(...).send(:start)

    # rubocop:enable Layout/LineLength

    # Environment variable to override coverage_threshold
    # @api private
    # @private
    COVERAGE_THRESHOLD = 'COVERAGE_THRESHOLD'

    # Environment variable to override fail_on_low_coverage
    # @api private
    # @private
    FAIL_ON_LOW_COVERAGE = 'FAIL_ON_LOW_COVERAGE'

    # Environment variable to override list_uncovered_lines
    # @api private
    # @private
    LIST_UNCOVERED_LINES = 'LIST_UNCOVERED_LINES'

    # Default value for coverage_threshold
    # @api private
    # @private
    DEFAULT_TEST_COVERAGE_THRESHOLD = 100

    # Default value for fail_on_low_coverage
    # @api private
    # @private
    DEFAULT_FAIL_ON_LOW_COVERAGEERAGE = true

    # Default value for list_uncovered_lines
    # @api private
    # @private
    DEFAULT_LIST_UNCOVERED_LINES = false

    attr_reader :env, :simplecov_module, :start_config_block

    # The coverage threshold
    #
    # Searches the ENV, the value given in the `.start` method, and the default value
    # and returns the first value found.
    #
    # @return [Integer]
    #
    # @api private
    # @private
    #
    def coverage_threshold
      return env.fetch(COVERAGE_THRESHOLD).to_i if env.key?(COVERAGE_THRESHOLD)

      return @coverage_threshold.to_i unless @coverage_threshold.nil?

      DEFAULT_TEST_COVERAGE_THRESHOLD
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

      DEFAULT_FAIL_ON_LOW_COVERAGEERAGE
    end

    # Whether to list the lines not covered by tests
    #
    # Searches the ENV, the value given in the `.start` method, and the default value
    # and returns the first value found.
    #
    # @return [Boolean]
    #
    # @api private
    # @private
    #
    def list_uncovered_lines?
      return env_true?(LIST_UNCOVERED_LINES) if env.key?(LIST_UNCOVERED_LINES)

      return @list_uncovered_lines unless @list_uncovered_lines.nil?

      DEFAULT_LIST_UNCOVERED_LINES
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
      coverage_threshold: nil,
      fail_on_low_coverage: nil,
      list_uncovered_lines: nil,
      rspec_dry_run: ::RSpec.configuration.dry_run?,
      env: ENV,
      simplecov_module: ::SimpleCov,
      &start_config_block
    )
      @coverage_threshold = coverage_threshold
      @fail_on_low_coverage = fail_on_low_coverage
      @list_uncovered_lines = list_uncovered_lines
      @start_config_block = start_config_block
      @rspec_dry_run = rspec_dry_run
      @env = env
      @simplecov_module = simplecov_module
    end

    # rubocop:enable Metrics/ParameterLists

    # Set the at_exit hook and then configure and start SimpleCov
    # @return [Void]
    # @api private
    # @private
    def start
      simplecov_module.at_exit(&at_exit_hook)
      simplecov_module.start(&start_config_block)
    end

    # Called by SimpleCov.at_exit
    # @return [Proc]
    # @api private
    # @private
    def at_exit_hook
      lambda do
        simplecov_module.result.format!
        output_at_exit_report
        exit 1 if coverage_below_threshold? && fail_on_low_coverage?
      end
    end

    # Output the at_exit report
    # @return [Void]
    # @api private
    # @private
    def output_at_exit_report
      low_coverage_report if show_low_coverage_report?
      uncovered_lines_report if show_uncovered_lines_report?
      $stderr.puts if show_low_coverage_report? || show_uncovered_lines_report?
    end

    # Whether to show the low coverage
    # @return [Boolean]
    # @api private
    # @private
    def show_low_coverage_report? = coverage_below_threshold?

    # Whether the test coverage is below the threshold
    # @return [Boolean]
    # @api private
    # @private
    def coverage_below_threshold? = simplecov_module.result.covered_percent < coverage_threshold

    # Output the low coverage report
    # @return [Void]
    # @api private
    # @private
    def low_coverage_report
      $stderr.puts
      $stderr.print 'FAIL: ' if fail_on_low_coverage?
      $stderr.puts "Test coverage is below the low coverage threshold of #{coverage_threshold}%"
    end

    # Whether there are uncovered lines
    # @return [Boolean]
    # @api private
    def uncovered_lines_found? = simplecov_module.result.files.any? { |source_file| source_file.missed_lines.any? }

    # Whether to show the uncovered lines
    # @return [Boolean]
    # @api private
    # @private
    def show_uncovered_lines_report? = list_uncovered_lines? && uncovered_lines_found?

    # Output the uncovered lines
    # @return [Void]
    # @api private
    # @private
    def uncovered_lines_report
      $stderr.puts
      $stderr.puts "The following lines were not covered by tests:\n"
      simplecov_module.result.files.each do |source_file| # SimpleCov::SourceFile
        source_file.missed_lines.each do |line| # SimpleCov::SourceFile::Line
          $stderr.puts "  ./#{source_file.project_filename}:#{line.number}"
        end
      end
    end

    # Return `true` if the environment variable is set to a truthy value
    #
    # @example
    #   env_true?('LIST_UNCOVERED_LINES')
    #
    # @param name [String] the name of the environment variable
    # @return [Boolean]
    # @api private
    # @private
    #
    def env_true?(name)
      value = env.fetch(name, '').downcase
      %w[yes on true 1].include?(value)
    end
  end
end
