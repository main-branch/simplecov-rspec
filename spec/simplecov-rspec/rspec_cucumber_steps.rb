# frozen_string_literal: true

# A fake SimpleCov::SourceFile, built from Gherkin table rows
class FakeSourceFile
  attr_reader :project_filename, :missed_lines, :missed_branches, :missed_methods

  def initialize(project_filename)
    @project_filename = project_filename
    @missed_lines = []
    @missed_branches = []
    @missed_methods = []
  end
end

FakeLine = Struct.new(:number)
FakeBranch = Struct.new(:report_line, :type)
FakeMethod = Struct.new(:start_line, :label) do
  def to_s = label
end

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
end

RSpec.configure do |config|
  config.before(type: :feature) do
    @simplecov_module = double('SimpleCov', result: SimpleCovResult.new(self))
    allow(@simplecov_module).to receive(:at_exit)
    allow(@simplecov_module).to receive(:start).with(no_args)
  end
end

def fake_file(name) = (@fake_files ||= {})[name] ||= FakeSourceFile.new(name)

def build_processor(**)
  @rspec_result_processor = SimpleCov::RSpec.new(
    fail_on_low_coverage: false,
    rspec_dry_run: false,
    env: {},
    simplecov_module: @simplecov_module,
    **
  )
end

step 'list_uncovered is "line"' do
  build_processor(list_uncovered: :line)
end

step 'list_uncovered is "branch"' do
  build_processor(list_uncovered: :branch)
end

step 'list_uncovered is "method"' do
  build_processor(list_uncovered: :method)
end

step 'list_uncovered is "all"' do
  build_processor(list_uncovered: :all)
end

step 'list_uncovered is false' do
  build_processor(list_uncovered: false)
end

step 'list_uncovered is "all" and list_uncovered_detail is false' do
  build_processor(list_uncovered: :all, list_uncovered_detail: false)
end

step 'the following lines are missing coverage:' do |table|
  table.hashes.each { |row| fake_file(row['File']).missed_lines << FakeLine.new(row['Line'].to_i) }
end

step 'the following branches are missing coverage:' do |table|
  table.hashes.each do |row|
    fake_file(row['File']).missed_branches << FakeBranch.new(row['Line'].to_i, row['Type'])
  end
end

step 'the following methods are missing coverage:' do |table|
  table.hashes.each do |row|
    fake_file(row['File']).missed_methods << FakeMethod.new(row['Line'].to_i, row['Method'])
  end
end

step 'nothing is missing coverage' do
  @fake_files = {}
end

step 'the at_exit_hook is called' do
  @files_with_low_coverage = (@fake_files || {}).values
  capture_command_result do
    @rspec_result_processor.send(:at_exit_hook).call
  end
end

step 'stderr output should include:' do |string|
  expect(@captured_stderr.string).to include(string)
end

step 'stderr output should NOT include:' do |string|
  expect(@captured_stderr.string).not_to include(string)
end
