# frozen_string_literal: true

class SimpleCovResult
  def initialize(context)
    @context = context
  end

  def format!
    # Do Nothing
  end

  def files
    @context.instance_variable_get(:@files_with_low_coverage)
  end

  def covered_percent
    @context.instance_variable_get(:@code_coverage)
  end
end

RSpec.configure do |config|
  config.before(type: :feature) do
    @simplecov_module = double('SimpleCov', result: SimpleCovResult.new(self))
    allow(@simplecov_module).to receive(:at_exit)
    allow(@simplecov_module).to receive(:start).with(no_args)
  end
end

def code_covereage = @code_coverage

step 'the code coverage is below the threshold' do
  @code_coverage = 99
end

step 'the code coverage is equal to the threshold' do
  @code_coverage = 100
end

step 'fail_on_low_coverage? is true' do
  @rspec_result_processor = SimpleCov::RSpec.new(
    coverage_threshold: 100,
    fail_on_low_coverage: true,
    list_uncovered_lines: false,
    rspec_dry_run: false,
    env: {},
    simplecov_module: @simplecov_module
  )
  @rspec_result_processor.send(:start)
end

step 'fail_on_low_coverage? is false' do
  @rspec_result_processor = SimpleCov::RSpec.new(
    coverage_threshold: 100,
    fail_on_low_coverage: false,
    list_uncovered_lines: false,
    rspec_dry_run: false,
    env: {},
    simplecov_module: @simplecov_module
  )
  @rspec_result_processor.send(:start)
end

step 'list_uncovered_lines? is true' do
  @rspec_result_processor = SimpleCov::RSpec.new(
    coverage_threshold: 100,
    fail_on_low_coverage: false,
    list_uncovered_lines: true,
    rspec_dry_run: false,
    env: {},
    simplecov_module: @simplecov_module
  )
  @rspec_result_processor.send(:start)
end

step 'list_uncovered_lines? is false' do
  @rspec_result_processor = SimpleCov::RSpec.new(
    coverage_threshold: 100,
    fail_on_low_coverage: false,
    list_uncovered_lines: false,
    rspec_dry_run: false,
    env: {},
    simplecov_module: @simplecov_module
  )
  @rspec_result_processor.send(:start)
end

step 'the following lines are missing coverage:' do |table|
  @files = Hash.new { |hash, key| hash[key] = [] }
  table.hashes.each do |row|
    @files[row['File']] << row['Line'].to_i
  end

  @files_with_low_coverage = []
  @files.each_key do |file|
    @files_with_low_coverage <<
      Struct.new(:project_filename, :missed_lines).new(
        file,
        @files[file].map do |line|
          Struct.new(:number).new(line)
        end
      )
  end
end

step 'the at_exit_hook is called' do
  capture_command_result do
    @rspec_result_processor.send(:at_exit_hook).call
  end
end

step 'a SystemExit exception should be raised with a non-zero status code' do
  expect(@system_exit_exception).not_to be_nil
  expect(@system_exit_exception.status).not_to eq(0)
end

step 'a SystemExit exception should not be raised' do
  expect(@system_exit_exception).to be_nil
end

step 'stderr output should include:' do |string|
  expect(@captured_stderr.string).to include(string)
end

step 'stderr output should NOT include:' do |string|
  expect(@captured_stderr.string).not_to include(string)
end
