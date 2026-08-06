# frozen_string_literal: true

RSpec.describe SimpleCov::RSpec::DescribedSourceFiles do
  # A stand-in for an RSpec example group: what it describes, and what is nested in it
  def group(described_class, children: [])
    double('example group', described_class: described_class, children: children)
  end

  def source_of(constant) = Object.const_source_location(constant.name).first

  describe '.call' do
    it 'returns the file defining a described class' do
      groups = [group(SimpleCov::RSpec::UncoveredReport)]
      expect(described_class.call(example_groups: groups)).to eq([source_of(SimpleCov::RSpec::UncoveredReport)])
    end

    it 'returns nothing when there are no example groups' do
      expect(described_class.call(example_groups: [])).to eq([])
    end

    it 'includes the classes described by nested groups' do
      groups = [group(SimpleCov::RSpec::UncoveredReport, children: [group(described_class)])]
      expect(described_class.call(example_groups: groups)).to contain_exactly(
        source_of(SimpleCov::RSpec::UncoveredReport), source_of(described_class)
      )
    end

    it 'reports a file once, however many groups describe it' do
      groups = [
        group(SimpleCov::RSpec::UncoveredReport),
        group(SimpleCov::RSpec::UncoveredReport, children: [group(SimpleCov::RSpec::UncoveredReport)])
      ]
      expect(described_class.call(example_groups: groups)).to eq([source_of(SimpleCov::RSpec::UncoveredReport)])
    end

    it 'skips a group that describes something other than a module' do
      expect(described_class.call(example_groups: [group(nil), group('a string')])).to eq([])
    end

    it 'skips an anonymous class, which has no name to look up' do
      expect(described_class.call(example_groups: [group(Class.new)])).to eq([])
    end

    it 'skips a class defined in C, which has no Ruby source file' do
      expect(described_class.call(example_groups: [group(String)])).to eq([])
    end

    it 'skips a class whose constant is no longer reachable by name' do
      klass = Class.new
      Object.const_set(:ADescribedClassSinceRemoved, klass)
      Object.send(:remove_const, :ADescribedClassSinceRemoved)

      expect(described_class.call(example_groups: [group(klass)])).to eq([])
    end

    it 'defaults to the example groups of the current run' do
      expect(described_class.call).to include(source_of(described_class))
    end
  end
end

RSpec.describe SimpleCov::RSpec do
  describe '.described_source_files' do
    it 'returns the files defining the classes the current run described' do
      expect(described_class.described_source_files)
        .to include(Object.const_source_location('SimpleCov::RSpec::DescribedSourceFiles').first)
    end
  end
end
