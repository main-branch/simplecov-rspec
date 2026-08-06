# frozen_string_literal: true

module SimpleCov
  class RSpec
    # Finds the source files that define the classes an RSpec run described.
    #
    # This is the scope most people want from `list_uncovered_files:` on a focused run:
    # "report on the code I am actually testing". Deriving it means reaching into
    # `RSpec.world`, which is not part of RSpec's public API, so it lives here rather
    # than in each project's `spec_helper.rb`, where it could not be fixed centrally.
    #
    # @api private
    #
    module DescribedSourceFiles
      module_function

      # The source files defining the classes the run described
      #
      # A group that describes something other than a Module contributes nothing, as
      # does one whose described class is anonymous, defined in C, or no longer
      # reachable by name. Such a group has no source file to report on, and saying so
      # is not useful, so it is skipped silently.
      #
      # @param example_groups [Array<Class>] the run's top-level example groups
      #
      # @return [Array<String>] absolute paths, without duplicates
      #
      # @example
      #   DescribedSourceFiles.call # => ['/project/lib/parser.rb']
      #
      # @api private
      #
      def call(example_groups: ::RSpec.world.example_groups)
        with_nested(example_groups).filter_map { |group| source_file(group) }.uniq
      end

      # The given example groups, plus every group nested within them
      #
      # A nested group can describe a different class than the group containing it, so
      # the whole tree is walked rather than just the top level.
      #
      # @param groups [Array<Class>] the example groups to walk
      #
      # @return [Array<Class>]
      #
      # @example
      #   DescribedSourceFiles.with_nested(::RSpec.world.example_groups)
      #
      # @api private
      #
      def with_nested(groups)
        groups.flat_map { |group| [group, *with_nested(group.children)] }
      end

      # The source file defining one group's described class, if it has one
      #
      # @param group [Class] the example group
      #
      # @return [String, nil] an absolute path, or nil if there is nothing to report on
      #
      # @example
      #   DescribedSourceFiles.source_file(group) # => '/project/lib/parser.rb'
      #
      # @api private
      #
      def source_file(group)
        described_class = group.described_class
        return nil unless described_class.is_a?(Module)

        # A class defined in C answers [], one whose constant is gone answers nil
        name = described_class.name
        name && Object.const_source_location(name)&.first
      end
    end
  end
end
