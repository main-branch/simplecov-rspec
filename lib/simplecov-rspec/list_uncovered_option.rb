# frozen_string_literal: true

module SimpleCov
  class RSpec
    # Resolves the `list_uncovered:` option (plus its `LIST_UNCOVERED` ENV override)
    # into a normalized Array<Symbol>, in a fixed line/branch/method order.
    #
    # @api private
    #
    module ListUncoveredOption
      # The coverage criteria this gem knows how to report on
      ALL_CRITERIA = %i[line branch method].freeze

      # LIST_UNCOVERED environment variable values that mean "every criterion"
      ALL_ENV_VALUES = %w[yes on true 1 all].freeze

      # LIST_UNCOVERED environment variable values that mean "no criteria"
      NONE_ENV_VALUES = %w[false no off 0].freeze

      module_function

      # Resolve the effective criteria, applying the ENV override if present
      # @param value [false, :all, Symbol, Array<Symbol>] the `list_uncovered:` argument
      # @param env [Hash] the environment variables
      # @param env_var [String] the ENV var name that overrides `value`
      # @return [Array<Symbol>]
      # @raise [ArgumentError] if value is not one of the accepted forms, or names an unknown criterion
      # @example
      #   ListUncoveredOption.resolve(:all, env: {}, env_var: 'LIST_UNCOVERED') # => [:line, :branch, :method]
      def resolve(value, env:, env_var:)
        value = from_env(env.fetch(env_var)) if env.key?(env_var)
        ALL_CRITERIA & normalize(value)
      end

      # Parse a raw LIST_UNCOVERED environment variable value
      # @param raw [String] the raw LIST_UNCOVERED environment variable value
      # @return [false, :all, Array<Symbol>]
      # @example
      #   ListUncoveredOption.from_env('line,branch') # => [:line, :branch]
      def from_env(raw)
        raw = raw.strip.downcase
        return false if raw.empty? || NONE_ENV_VALUES.include?(raw)
        return :all if ALL_ENV_VALUES.include?(raw)

        raw.split(',').map { |criterion| criterion.strip.to_sym }
      end

      # Normalize a `list_uncovered:`-style value into an Array of Symbols
      # @param value [false, true, :all, Symbol, Array<Symbol>]
      # @return [Array<Symbol>]
      # @example
      #   ListUncoveredOption.normalize(:branch) # => [:branch]
      def normalize(value)
        case value
        when nil, false then []
        when :all       then ALL_CRITERIA
        when Symbol     then validate([value])
        when Array      then validate(value)
        else
          raise ArgumentError,
                "list_uncovered must be false, :all, a Symbol, or an Array of Symbols; got #{value.inspect}"
        end
      end

      # Raise unless every given criterion is one this gem knows how to report on
      # @param criteria [Array<Symbol>]
      # @return [Array<Symbol>]
      # @raise [ArgumentError] if criteria contains anything outside ALL_CRITERIA
      # @example
      #   ListUncoveredOption.validate([:line]) # => [:line]
      def validate(criteria)
        invalid = criteria - ALL_CRITERIA
        return criteria if invalid.empty?

        raise ArgumentError, "Unknown coverage criterion #{invalid.inspect}; must be one of #{ALL_CRITERIA.inspect}"
      end
    end
  end
end
