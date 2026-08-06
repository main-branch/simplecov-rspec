# frozen_string_literal: true

# The SimpleCov.root the fake SimpleCov module reports, and that relative
# list_uncovered_files patterns are resolved against. Deliberately a directory that does
# not exist, so that a pattern never accidentally globs a real file.
FAKE_SIMPLECOV_ROOT = '/fake/project'

# Paths to files that really exist, but that the fake SimpleCov result never contains.
# Lets a scenario tell "your pattern matched nothing" apart from "SimpleCov never saw
# the file your pattern matched", which are reported differently.
REAL_UNTRACKED_FILES = [
  File.expand_path('../../lib/simplecov-rspec.rb', __dir__),
  File.expand_path('../../lib/simplecov-rspec/uncovered_report.rb', __dir__)
].freeze

# A fake SimpleCov::SourceFile, built from Gherkin table rows
class FakeSourceFile
  attr_reader :project_filename, :missed_lines, :missed_branches, :missed_methods
  attr_accessor :covered_lines, :covered_branches, :covered_methods

  def initialize(project_filename)
    @project_filename = project_filename
    @missed_lines = []
    @missed_branches = []
    @missed_methods = []
    @covered_lines = []
    @covered_branches = []
    @covered_methods = []
  end

  # The absolute path, as SimpleCov::SourceFile reports it
  def filename = File.join(FAKE_SIMPLECOV_ROOT, project_filename)
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
    allow(@simplecov_module).to receive(:root).and_return(FAKE_SIMPLECOV_ROOT)
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

step 'list_uncovered is :criteria and list_uncovered_files is :pattern' do |criteria, pattern|
  build_processor(list_uncovered: criteria.to_sym, list_uncovered_files: pattern)
end

step 'list_uncovered is :criteria and list_uncovered_files is :first and :second' do |criteria, first, second|
  build_processor(list_uncovered: criteria.to_sym, list_uncovered_files: [first, second])
end

step 'list_uncovered is :criteria and list_uncovered_files is :pattern and list_uncovered_detail is false' \
  do |criteria, pattern|
  build_processor(list_uncovered: criteria.to_sym, list_uncovered_files: pattern, list_uncovered_detail: false)
end

step 'list_uncovered is :criteria and list_uncovered_files is a callable returning :pattern' do |criteria, pattern|
  build_processor(list_uncovered: criteria.to_sym, list_uncovered_files: -> { pattern })
end

step 'list_uncovered is :criteria and the LIST_UNCOVERED_FILES environment variable is :pattern' \
  do |criteria, pattern|
  build_processor(list_uncovered: criteria.to_sym, env: { 'LIST_UNCOVERED_FILES' => pattern })
end

step 'list_uncovered is :criteria and list_uncovered_files is a file that exists but was not loaded' do |criteria|
  build_processor(list_uncovered: criteria.to_sym, list_uncovered_files: REAL_UNTRACKED_FILES.first)
end

step 'list_uncovered is :criteria and list_uncovered_files is two files that exist but were not loaded' \
  do |criteria|
  build_processor(list_uncovered: criteria.to_sym, list_uncovered_files: REAL_UNTRACKED_FILES)
end

step 'list_uncovered is :criteria and list_uncovered_files resolves to no files at all' do |criteria|
  build_processor(list_uncovered: criteria.to_sym, list_uncovered_files: -> { [] })
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

step 'the following files are fully covered:' do |table|
  table.hashes.each { |row| fake_file(row['File']) }
end

# Covered counts are all this gem needs -- it reports how many, never which ones
step 'the following items are covered:' do |table|
  table.hashes.each do |row|
    file = fake_file(row['File'])
    file.covered_lines = Array.new(row['Lines'].to_i) { |i| FakeLine.new(i + 1) }
    file.covered_branches = Array.new(row['Branches'].to_i) { |i| FakeBranch.new(i + 1, 'then') }
    file.covered_methods = Array.new(row['Methods'].to_i) { |i| FakeMethod.new(i + 1, 'm') }
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
