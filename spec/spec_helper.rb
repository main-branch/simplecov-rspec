# frozen_string_literal: true

# RSpec configuration
#
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Turnip configuration
#
require 'turnip/rspec'
Dir[File.join(__dir__, '**/*_steps.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# rubocop:disable Metrics/MethodLength

def capture_command_result(&command_block)
  saved_stdout = $stdout
  @captured_stdout = StringIO.new
  $stdout = @captured_stdout

  saved_stderr = $stderr
  @captured_stderr = StringIO.new
  $stderr = @captured_stderr

  @result = command_block.call
rescue SystemExit => e
  @system_exit_exception = e
ensure
  $stdout = saved_stdout
  $stderr = saved_stderr
end

# rubocop:enable Metrics/MethodLength

# SimpleCov configuration
#
require 'simplecov'
require 'simplecov-lcov'

if ENV.fetch('GITHUB_ACTIONS', 'false') == 'true'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
end

SimpleCov.start

# Require this project's files last
#
require 'simplecov/rspec'
