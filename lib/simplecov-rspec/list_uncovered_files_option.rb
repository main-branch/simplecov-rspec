# frozen_string_literal: true

module SimpleCov
  class RSpec
    # Resolves the `list_uncovered_files:` option (plus its `LIST_UNCOVERED_FILES` ENV
    # override) into a normalized Array of absolute paths, or nil for "every file".
    #
    # The option may be given as a callable so that it can be evaluated after the test
    # run rather than when `SimpleCov::RSpec.start` is called. `start` runs before any
    # example is defined, so a caller that wants to scope the report to the code under
    # test cannot know which files those are yet.
    #
    # @api private
    #
    module ListUncoveredFilesOption
      # LIST_UNCOVERED_FILES environment variable values that mean "every file"
      ALL_ENV_VALUES = %w[all false no off 0].freeze

      module_function

      # Resolve the effective file list, applying the ENV override if present
      #
      # @param value [nil, String, Array<String>, #call] the `list_uncovered_files:` argument
      # @param env [Hash] the environment variables
      # @param env_var [String] the ENV var name that overrides `value`
      # @param root [String] the directory that relative patterns are resolved against
      #
      # @return [Array<String>, nil] absolute paths, or nil to report on every file
      #
      # @raise [ArgumentError] if value is not one of the accepted forms
      #
      # @example
      #   ListUncoveredFilesOption.resolve('lib/a.rb', env: {}, env_var: 'X', root: '/p') # => ['/p/lib/a.rb']
      #
      def resolve(value, env:, env_var:, root:)
        value = from_env(env.fetch(env_var)) if env.key?(env_var)
        value = value.call if value.respond_to?(:call)
        return nil if value.nil?

        expand(normalize(value), root)
      end

      # Parse a raw LIST_UNCOVERED_FILES environment variable value
      #
      # A value that lists no patterns at all — `''`, `'  '`, or separators alone such as
      # `', ,'` — means "every file". Dropping the empty entries can empty the list even
      # though the value was not empty to start with, so the check is made after parsing
      # as well as before it.
      #
      # @param raw [String] the raw LIST_UNCOVERED_FILES environment variable value
      # @return [nil, Array<String>] nil for "every file", otherwise the listed patterns
      # @example
      #   ListUncoveredFilesOption.from_env('lib/a.rb,lib/b.rb') # => ['lib/a.rb', 'lib/b.rb']
      #
      def from_env(raw)
        stripped = raw.strip
        return nil if stripped.empty? || ALL_ENV_VALUES.include?(stripped.downcase)

        patterns = stripped.split(',').map(&:strip).reject(&:empty?)
        patterns.empty? ? nil : patterns
      end

      # Normalize a `list_uncovered_files:`-style value into an Array of Strings
      #
      # @param value [String, Array<String>] the pattern or patterns
      # @return [Array<String>]
      # @raise [ArgumentError] if value is not a String or an Array of Strings
      # @example
      #   ListUncoveredFilesOption.normalize('lib/a.rb') # => ['lib/a.rb']
      #
      def normalize(value)
        case value
        when String then [value]
        when Array then validate(value)
        else
          raise ArgumentError,
                'list_uncovered_files must be nil, a String, an Array of Strings, or a callable returning one ' \
                "of those; got #{value.inspect}"
        end
      end

      # Raise unless every element of patterns is a String
      #
      # @param patterns [Array<String>]
      # @return [Array<String>]
      # @raise [ArgumentError] if patterns contains a non-String
      # @example
      #   ListUncoveredFilesOption.validate(['lib/a.rb']) # => ['lib/a.rb']
      #
      def validate(patterns)
        invalid = patterns.grep_v(String)
        return patterns if invalid.empty?

        raise ArgumentError, "list_uncovered_files entries must be Strings; got #{invalid.inspect}"
      end

      # Expand patterns to absolute paths, resolving relative patterns against root
      #
      # Each pattern is expanded with `Dir.glob`. A pattern that matches nothing on disk
      # expands to itself, so the literal pattern is kept rather than dropped. No file in
      # the coverage result can carry that path, so it adds nothing to the listing; it is
      # kept because the report tests these paths against the file system to tell a
      # pattern that matched nothing from one whose files SimpleCov never tracked.
      #
      # @param patterns [Array<String>] the patterns to expand
      # @param root [String] the directory that relative patterns are resolved against
      # @return [Array<String>] absolute paths, without duplicates
      # @example
      #   ListUncoveredFilesOption.expand(['lib/*.rb'], '/p') # => ['/p/lib/a.rb', '/p/lib/b.rb']
      #
      def expand(patterns, root)
        patterns.flat_map do |pattern|
          absolute = File.absolute_path(pattern, root)
          matches = Dir.glob(absolute)
          matches.empty? ? [absolute] : matches
        end.uniq
      end
    end
  end
end
