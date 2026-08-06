# frozen_string_literal: true

RSpec.describe SimpleCov::RSpec do
  describe '.new' do
    context 'when created with no arguments' do
      it 'has the default configuration' do
        expect(described_class.new).to have_attributes(
          minimum_coverage: { line: 100 },
          fail_on_low_coverage?: true,
          list_uncovered_criteria: [],
          list_uncovered_detail?: true,
          list_uncovered_files: nil,
          rspec_dry_run?: RSpec.configuration.dry_run?,
          simplecov_module: SimpleCov,
          env: ENV,
          start_config_block: nil
        )
      end
    end

    context 'when created with arguments' do
      let(:subject) { described_class.new(**actual_arguments) }

      context 'when minimum_coverage is an Integer' do
        let(:actual_arguments) { { minimum_coverage: 90 } }

        it 'sets the line coverage threshold' do
          expect(subject).to have_attributes(minimum_coverage: { line: 90 })
        end
      end

      context 'when minimum_coverage is a Hash' do
        let(:actual_arguments) { { minimum_coverage: { line: 100, branch: 90 } } }

        it 'is passed through unchanged' do
          expect(subject).to have_attributes(minimum_coverage: { line: 100, branch: 90 })
        end
      end

      context 'when minimum_coverage is neither nil, an Integer, nor a Hash' do
        let(:actual_arguments) { { minimum_coverage: '90' } }

        it 'raises ArgumentError' do
          expect { subject.minimum_coverage }.to raise_error(
            ArgumentError, 'minimum_coverage must be nil, an Integer, or a Hash; got "90"'
          )
        end
      end

      context 'when minimum_coverage is a Hash with an unknown key' do
        let(:actual_arguments) { { minimum_coverage: { 'line' => 100 } } }

        it 'raises ArgumentError' do
          expect { subject.minimum_coverage }.to raise_error(
            ArgumentError, 'minimum_coverage keys must be [:line, :branch, :method]; got "line"'
          )
        end
      end

      context 'when minimum_coverage is a Hash with a non-Numeric value' do
        let(:actual_arguments) { { minimum_coverage: { line: '90' } } }

        it 'raises ArgumentError' do
          expect { subject.minimum_coverage }.to raise_error(
            ArgumentError, 'minimum_coverage[:line] must be a Numeric; got "90"'
          )
        end
      end

      context 'when all arguments have non-default values' do
        let(:actual_arguments) do
          {
            minimum_coverage: { line: 90 },
            fail_on_low_coverage: false,
            list_uncovered: :all,
            list_uncovered_detail: false,
            list_uncovered_files: 'lib/simplecov-rspec.rb',
            env: {}
          }
        end

        it 'has the given configuration' do
          expect(subject).to have_attributes(
            minimum_coverage: { line: 90 },
            fail_on_low_coverage?: false,
            list_uncovered_criteria: %i[line branch method],
            list_uncovered_detail?: false,
            list_uncovered_files: [File.join(SimpleCov.root, 'lib/simplecov-rspec.rb')],
            env: {}
          )
        end
      end
    end

    context 'when RSpec is in dry-run mode' do
      context 'when fail_on_low_coverage is default (true)' do
        it 'should return false for fail_on_low_coverage?' do
          subject = described_class.new(rspec_dry_run: true)
          expect(subject.fail_on_low_coverage?).to eq(false)
        end
      end
      context 'when fail_on_low_coverage is explicitly set to true' do
        it 'should return false for fail_on_low_coverage?' do
          subject = described_class.new(fail_on_low_coverage: true, rspec_dry_run: true)
          expect(subject.fail_on_low_coverage?).to eq(false)
        end
      end
      context 'when the environment variable FAIL_ON_LOW_COVERAGE is set to true' do
        it 'should return false for fail_on_low_coverage?' do
          subject = described_class.new(rspec_dry_run: true, env: { 'FAIL_ON_LOW_COVERAGE' => 'true' })
          expect(subject.fail_on_low_coverage?).to eq(false)
        end
      end
    end

    describe '#list_uncovered_criteria' do
      it 'accepts false' do
        expect(described_class.new(list_uncovered: false).list_uncovered_criteria).to eq([])
      end

      it 'accepts :all' do
        expect(described_class.new(list_uncovered: :all).list_uncovered_criteria).to eq(%i[line branch method])
      end

      it 'accepts a single Symbol' do
        expect(described_class.new(list_uncovered: :branch).list_uncovered_criteria).to eq([:branch])
      end

      it 'accepts an Array of Symbols' do
        criteria = described_class.new(list_uncovered: %i[method line]).list_uncovered_criteria
        expect(criteria).to eq(%i[line method])
      end

      it 'canonicalizes order to line, branch, method regardless of input order' do
        criteria = described_class.new(list_uncovered: %i[branch line]).list_uncovered_criteria
        expect(criteria).to eq(%i[line branch])
      end

      it 'raises ArgumentError for an unknown criterion' do
        expect { described_class.new(list_uncovered: :statement).list_uncovered_criteria }
          .to raise_error(ArgumentError, /Unknown coverage criterion/)
      end

      it 'raises ArgumentError for an unsupported value' do
        expect { described_class.new(list_uncovered: true).list_uncovered_criteria }
          .to raise_error(ArgumentError, /list_uncovered must be/)
      end
    end

    describe '#list_uncovered_files' do
      let(:root) { SimpleCov.root }

      it 'returns nil by default, meaning every file in the result' do
        expect(described_class.new(env: {}).list_uncovered_files).to be_nil
      end

      it 'returns nil when explicitly given nil' do
        expect(described_class.new(list_uncovered_files: nil, env: {}).list_uncovered_files).to be_nil
      end

      it 'wraps a single String in an Array of absolute paths' do
        subject = described_class.new(list_uncovered_files: 'lib/no_such_file.rb', env: {})
        expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/no_such_file.rb')])
      end

      it 'resolves an Array of patterns, without duplicates' do
        subject = described_class.new(list_uncovered_files: ['lib/a.rb', 'lib/b.rb', 'lib/a.rb'], env: {})
        expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/a.rb'), File.join(root, 'lib/b.rb')])
      end

      it 'leaves an absolute pattern alone' do
        subject = described_class.new(list_uncovered_files: '/somewhere/else/a.rb', env: {})
        expect(subject.list_uncovered_files).to eq(['/somewhere/else/a.rb'])
      end

      it 'expands a glob that matches files on disk' do
        subject = described_class.new(list_uncovered_files: 'lib/simplecov-rspec/*_option.rb', env: {})
        expect(subject.list_uncovered_files).to contain_exactly(
          File.join(root, 'lib/simplecov-rspec/list_uncovered_option.rb'),
          File.join(root, 'lib/simplecov-rspec/list_uncovered_files_option.rb')
        )
      end

      it 'keeps a pattern that matches nothing as a literal path' do
        subject = described_class.new(list_uncovered_files: 'lib/**/no_such_file.rb', env: {})
        expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/**/no_such_file.rb')])
      end

      it 'calls a callable, and resolves what it returns' do
        subject = described_class.new(list_uncovered_files: -> { 'lib/a.rb' }, env: {})
        expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/a.rb')])
      end

      it 'returns nil when a callable returns nil' do
        expect(described_class.new(list_uncovered_files: -> {}, env: {}).list_uncovered_files).to be_nil
      end

      it 'resolves the callable on each call, not once at start' do
        values = ['lib/a.rb', 'lib/b.rb']
        subject = described_class.new(list_uncovered_files: -> { values.shift }, env: {})
        expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/a.rb')])
        expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/b.rb')])
      end

      it 'resolves :described to the files defining the classes the run described' do
        allow(described_class).to receive(:described_source_files).and_return(['/project/lib/parser.rb'])
        subject = described_class.new(list_uncovered_files: :described, env: {})
        expect(subject.list_uncovered_files).to eq(['/project/lib/parser.rb'])
      end

      it 'resolves :described after the run, not at start' do
        allow(described_class).to receive(:described_source_files).and_return([])
        subject = described_class.new(list_uncovered_files: :described, env: {})
        expect(described_class).not_to have_received(:described_source_files)
        subject.list_uncovered_files
        expect(described_class).to have_received(:described_source_files)
      end

      it 'raises ArgumentError when given something other than a String or Array' do
        expect { described_class.new(list_uncovered_files: :lib, env: {}).list_uncovered_files }.to raise_error(
          ArgumentError,
          'list_uncovered_files must be nil, :described, a String, an Array of Strings, or a callable ' \
          'returning one of those; got :lib'
        )
      end

      it 'raises ArgumentError when an Array entry is not a String' do
        expect { described_class.new(list_uncovered_files: ['lib/a.rb', :b], env: {}).list_uncovered_files }
          .to raise_error(ArgumentError, 'list_uncovered_files entries must be Strings; got [:b]')
      end
    end

    context 'with ENV variable overrides' do
      context 'when COVERAGE_THRESHOLD is set' do
        it 'should override the default minimum_coverage[:line]' do
          subject = described_class.new(env: { 'COVERAGE_THRESHOLD' => '89' })
          expect(subject).to have_attributes(minimum_coverage: { line: 89 })
        end

        it 'should override the given minimum_coverage[:line]' do
          subject = described_class.new(minimum_coverage: 95, env: { 'COVERAGE_THRESHOLD' => '89' })
          expect(subject).to have_attributes(minimum_coverage: { line: 89 })
        end
      end

      context 'when COVERAGE_THRESHOLD_BRANCH and COVERAGE_THRESHOLD_METHOD are set' do
        it 'sets minimum_coverage for those criteria, in addition to any given ones' do
          subject = described_class.new(
            minimum_coverage: { line: 100 },
            env: { 'COVERAGE_THRESHOLD_BRANCH' => '90', 'COVERAGE_THRESHOLD_METHOD' => '80' }
          )
          expect(subject).to have_attributes(minimum_coverage: { line: 100, branch: 90, method: 80 })
        end
      end

      context 'when FAIL_ON_LOW_COVERAGE is set' do
        it 'should override the default fail_on_low_coverage' do
          subject = described_class.new(env: { 'FAIL_ON_LOW_COVERAGE' => 'false' })
          expect(subject).to have_attributes(fail_on_low_coverage?: false)
          subject = described_class.new(env: { 'FAIL_ON_LOW_COVERAGE' => 'true' })
          expect(subject).to have_attributes(fail_on_low_coverage?: true)
        end

        it 'should override the given fail_on_low_coverage' do
          subject = described_class.new(fail_on_low_coverage: true, env: { 'FAIL_ON_LOW_COVERAGE' => 'false' })
          expect(subject).to have_attributes(fail_on_low_coverage?: false)
          subject = described_class.new(fail_on_low_coverage: false, env: { 'FAIL_ON_LOW_COVERAGE' => 'true' })
          expect(subject).to have_attributes(fail_on_low_coverage?: true)
        end
      end

      context 'when LIST_UNCOVERED is set' do
        it 'overrides the default list_uncovered' do
          subject = described_class.new(env: { 'LIST_UNCOVERED' => 'all' })
          expect(subject).to have_attributes(list_uncovered_criteria: %i[line branch method])
        end

        it 'overrides the given list_uncovered' do
          subject = described_class.new(list_uncovered: :all, env: { 'LIST_UNCOVERED' => 'false' })
          expect(subject).to have_attributes(list_uncovered_criteria: [])
        end

        it 'accepts a comma-separated list of criteria' do
          subject = described_class.new(env: { 'LIST_UNCOVERED' => 'branch,line' })
          expect(subject).to have_attributes(list_uncovered_criteria: %i[line branch])
        end

        %w[true yes on 1 all].each do |value|
          it "treats #{value.inspect} as :all" do
            subject = described_class.new(env: { 'LIST_UNCOVERED' => value })
            expect(subject).to have_attributes(list_uncovered_criteria: %i[line branch method])
          end
        end

        %w[false no off 0].each do |value|
          it "treats #{value.inspect} as no criteria" do
            subject = described_class.new(env: { 'LIST_UNCOVERED' => value })
            expect(subject).to have_attributes(list_uncovered_criteria: [])
          end
        end
      end

      context 'when LIST_UNCOVERED_FILES is set' do
        let(:root) { SimpleCov.root }

        it 'overrides the default list_uncovered_files' do
          subject = described_class.new(env: { 'LIST_UNCOVERED_FILES' => 'lib/a.rb' })
          expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/a.rb')])
        end

        it 'overrides the given list_uncovered_files' do
          subject = described_class.new(list_uncovered_files: 'lib/a.rb', env: { 'LIST_UNCOVERED_FILES' => 'lib/b.rb' })
          expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/b.rb')])
        end

        it 'accepts a comma-separated list of patterns, ignoring surrounding whitespace' do
          subject = described_class.new(env: { 'LIST_UNCOVERED_FILES' => ' lib/a.rb , lib/b.rb ' })
          expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/a.rb'), File.join(root, 'lib/b.rb')])
        end

        it 'ignores empty entries in the list' do
          subject = described_class.new(env: { 'LIST_UNCOVERED_FILES' => 'lib/a.rb,,lib/b.rb' })
          expect(subject.list_uncovered_files).to eq([File.join(root, 'lib/a.rb'), File.join(root, 'lib/b.rb')])
        end

        %w[all false no off 0 ALL].each do |value|
          it "treats #{value.inspect} as every file" do
            subject = described_class.new(list_uncovered_files: 'lib/a.rb', env: { 'LIST_UNCOVERED_FILES' => value })
            expect(subject.list_uncovered_files).to be_nil
          end
        end

        it 'treats an empty value as every file' do
          subject = described_class.new(list_uncovered_files: 'lib/a.rb', env: { 'LIST_UNCOVERED_FILES' => '  ' })
          expect(subject.list_uncovered_files).to be_nil
        end

        it 'treats a value with no patterns as every file' do
          subject = described_class.new(list_uncovered_files: 'lib/a.rb', env: { 'LIST_UNCOVERED_FILES' => ', ,' })
          expect(subject.list_uncovered_files).to be_nil
        end

        %w[described DESCRIBED].each do |value|
          it "treats #{value.inspect} as the files defining the described classes" do
            allow(described_class).to receive(:described_source_files).and_return(['/project/lib/parser.rb'])
            subject = described_class.new(list_uncovered_files: 'lib/a.rb', env: { 'LIST_UNCOVERED_FILES' => value })
            expect(subject.list_uncovered_files).to eq(['/project/lib/parser.rb'])
          end
        end
      end

      context 'when LIST_UNCOVERED_DETAIL is set' do
        it 'should override the default list_uncovered_detail' do
          subject = described_class.new(env: { 'LIST_UNCOVERED_DETAIL' => 'false' })
          expect(subject).to have_attributes(list_uncovered_detail?: false)
          subject = described_class.new(env: { 'LIST_UNCOVERED_DETAIL' => 'true' })
          expect(subject).to have_attributes(list_uncovered_detail?: true)
        end

        it 'should override the given list_uncovered_detail' do
          subject = described_class.new(list_uncovered_detail: true, env: { 'LIST_UNCOVERED_DETAIL' => 'false' })
          expect(subject).to have_attributes(list_uncovered_detail?: false)
          subject = described_class.new(list_uncovered_detail: false, env: { 'LIST_UNCOVERED_DETAIL' => 'true' })
          expect(subject).to have_attributes(list_uncovered_detail?: true)
        end
      end
    end
  end

  describe '#start' do
    let(:simplecov_module) { double('SimpleCov') }

    before do
      allow(simplecov_module).to receive(:at_exit)
      allow(simplecov_module).to receive(:enable_coverage)
      allow(simplecov_module).to receive(:minimum_coverage)
      allow(simplecov_module).to receive(:start)
    end

    it 'should call SimpleCov.start' do
      subject = described_class.new(simplecov_module:)
      expected_hook_proc = subject.send(:at_exit_hook).to_proc
      expect(simplecov_module).to receive(:at_exit) do |&block|
        # Verify that the block passed to #at_exit is equivalent to the expected hook proc
        expect(block.binding.receiver).to eq(expected_hook_proc.binding.receiver)
        expect(block.source_location).to eq(expected_hook_proc.source_location)
      end
      subject.send(:start)
      expect(simplecov_module).to have_received(:start)
    end

    it 'should enable the coverage criteria needed for minimum_coverage and list_uncovered' do
      subject = described_class.new(
        simplecov_module:, minimum_coverage: { line: 100 }, list_uncovered: :branch
      )
      subject.send(:start)
      expect(simplecov_module).to have_received(:enable_coverage).with(:line, :branch)
    end

    it 'should not enable any coverage criteria when none are needed' do
      subject = described_class.new(simplecov_module:, minimum_coverage: {}, list_uncovered: false)
      subject.send(:start)
      expect(simplecov_module).not_to have_received(:enable_coverage)
    end

    it 'should set SimpleCov.minimum_coverage when fail_on_low_coverage is true' do
      subject = described_class.new(simplecov_module:, minimum_coverage: { line: 90 })
      subject.send(:start)
      expect(simplecov_module).to have_received(:minimum_coverage).with({ line: 90 })
    end

    it 'should not set SimpleCov.minimum_coverage when fail_on_low_coverage is false' do
      subject = described_class.new(simplecov_module:, fail_on_low_coverage: false)
      subject.send(:start)
      expect(simplecov_module).not_to have_received(:minimum_coverage)
    end

    it 'should not set SimpleCov.minimum_coverage when RSpec is in dry-run mode' do
      subject = described_class.new(simplecov_module:, rspec_dry_run: true)
      subject.send(:start)
      expect(simplecov_module).not_to have_received(:minimum_coverage)
    end

    context 'when a start_config_block is set' do
      it 'should call SimpleCov.start with that block' do
        start_config_block = proc {}
        subject = described_class.new(simplecov_module:, &start_config_block)
        expect(simplecov_module).to receive(:start) do |&block|
          expect(block.binding.receiver).to eq(start_config_block.binding.receiver)
          expect(block.source_location).to eq(start_config_block.source_location)
        end
        subject.send(:start)
      end
    end
  end
end
