# frozen_string_literal: true

RSpec.describe SimpleCov::RSpec do
  describe '.new' do
    let(:default_arguments) do
      {
        coverage_threshold: 100,
        fail_on_low_coverage: true,
        list_uncovered_lines: false,
        rspec_dry_run: false,
        env: ENV
      }
    end

    context 'when created with no arguments' do
      it 'has the default configuration' do
        expect(described_class.new).to have_attributes(
          coverage_threshold: 100,
          fail_on_low_coverage?: true,
          list_uncovered_lines?: false,
          rspec_dry_run?: RSpec.configuration.dry_run?,
          simplecov_module: SimpleCov,
          env: ENV,
          start_config_block: nil
        )
      end
    end

    context 'when created with arguments' do
      let(:subject) { described_class.new(**actual_arguments) }

      context 'when all arguments have default values' do
        let(:actual_arguments) { default_arguments }

        let!(:expected_attributes) do
          {
            coverage_threshold: 100,
            fail_on_low_coverage?: true,
            list_uncovered_lines?: false,
            env: ENV
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
      end

      context 'when all arguments have non-default values' do
        let(:actual_arguments) do
          {
            coverage_threshold: 90,
            fail_on_low_coverage: false,
            list_uncovered_lines: true,
            env: {}
          }
        end

        let!(:expected_attributes) do
          {
            coverage_threshold: 90,
            fail_on_low_coverage?: false,
            list_uncovered_lines?: true,
            env: {}
          }
        end

        it { is_expected.to have_attributes(expected_attributes) }
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

    context 'with ENV variable overrides' do
      context 'when COVERAGE_THRESHOLD is set' do
        it 'should override the default coverage_threshold' do
          subject = described_class.new(env: { 'COVERAGE_THRESHOLD' => '89' })
          expect(subject).to have_attributes(coverage_threshold: 89)
        end

        it 'should override the given coverage_threshold' do
          subject = described_class.new(coverage_threshold: 95, env: { 'COVERAGE_THRESHOLD' => '89' })
          expect(subject).to have_attributes(coverage_threshold: 89)
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
          subject = described_class.new(env: { fail_on_low_coverage: false, 'FAIL_ON_LOW_COVERAGE' => 'true' })
          expect(subject).to have_attributes(fail_on_low_coverage?: true)
        end
      end

      context 'when LIST_UNCOVERED_LINES is set' do
        it 'should override the default fail_on_low_coverage' do
          subject = described_class.new(env: { 'LIST_UNCOVERED_LINES' => 'false' })
          expect(subject).to have_attributes(list_uncovered_lines?: false)
          subject = described_class.new(env: { 'LIST_UNCOVERED_LINES' => 'true' })
          expect(subject).to have_attributes(list_uncovered_lines?: true)
        end

        it 'should override the given fail_on_low_coverage' do
          subject = described_class.new(list_uncovered_lines: true, env: { 'LIST_UNCOVERED_LINES' => 'false' })
          expect(subject).to have_attributes(list_uncovered_lines?: false)
          subject = described_class.new(env: { list_uncovered_lines: false, 'LIST_UNCOVERED_LINES' => 'true' })
          expect(subject).to have_attributes(list_uncovered_lines?: true)
        end
      end
    end
  end

  describe '#start' do
    let(:simplecov_module) { double('SimpleCov') }

    it 'should call SimpleCov.start' do
      subject = described_class.new(simplecov_module:)
      expected_hook_proc = subject.send(:at_exit_hook).to_proc
      expect(simplecov_module).to receive(:at_exit) do |&block|
        # Verify that the block passed to #at_exit is equivalent to the expected hook proc
        expect(block.binding.receiver).to eq(expected_hook_proc.binding.receiver)
        expect(block.source_location).to eq(expected_hook_proc.source_location)
      end
      allow(simplecov_module).to receive(:start)
      subject.send(:start)
    end

    context 'when a start_config_block is set' do
      it 'should call SimpleCov.start with that block' do
        start_config_block = proc {}
        subject = described_class.new(simplecov_module:, &start_config_block)
        allow(simplecov_module).to receive(:at_exit)
        expect(simplecov_module).to receive(:start) do |&block|
          expect(block.binding.receiver).to eq(start_config_block.binding.receiver)
          expect(block.source_location).to eq(start_config_block.source_location)
        end
        subject.send(:start)
      end
    end
  end
end
