# frozen_string_literal: true

module SimpleCov
  class RSpec
    # Formats the "uncovered lines/branches/methods" report printed after a run: either
    # a full listing of every uncovered item, or a per-criterion count with a hint on
    # how to see the details.
    #
    # @api private
    #
    class UncoveredReport
      # Maps a coverage criterion to its [singular, plural] noun, for report formatting
      # @api private
      CRITERION_LABELS = {
        line: %w[line lines],
        branch: %w[branch branches],
        method: %w[method methods]
      }.freeze

      # Build a report for the given result, criteria, and detail level
      # @param result [SimpleCov::Result] the SimpleCov result to report on
      # @param criteria [Array<Symbol>] which criteria (:line, :branch, :method) to report
      # @param detail [Boolean] list individual items, or just a count per criterion
      # @param detail_env_var [String] the ENV var name to suggest for switching to detail
      # @example
      #   UncoveredReport.new(result: SimpleCov.result, criteria: [:line], detail: true, detail_env_var: 'X')
      def initialize(result:, criteria:, detail:, detail_env_var:)
        @result = result
        @criteria = criteria
        @detail = detail
        @detail_env_var = detail_env_var
      end

      # The formatted report text, or an empty string if there is nothing to report
      # @return [String]
      def to_s = detail ? detailed_text : summary_text

      private

      # The SimpleCov result being reported on
      # @return [SimpleCov::Result]
      # @api private
      attr_reader :result

      # Which criteria (:line, :branch, :method) to report on
      # @return [Array<Symbol>]
      # @api private
      attr_reader :criteria

      # Whether to list individual items, or just a count per criterion
      # @return [Boolean]
      # @api private
      attr_reader :detail

      # The ENV var name to suggest for switching to detail
      # @return [String]
      # @api private
      attr_reader :detail_env_var

      # The full listing, one blank-line-separated section per criterion
      # @return [String]
      def detailed_text
        criteria.filter_map { |criterion| section(criterion) }.join("\n\n")
      end

      # A criterion's report section, or nil when nothing is uncovered
      # @param criterion [Symbol]
      # @return [String, nil]
      def section(criterion)
        items = uncovered_items(criterion)
        return nil if items.empty?

        ["#{header(criterion, items.count)}:", *items.map { |item| "  #{item}" }].join("\n")
      end

      # The per-criterion counts, plus a hint on how to see the details
      # @return [String]
      def summary_text
        summarized = criteria.filter_map do |criterion|
          count = uncovered_count(criterion)
          [criterion, count] if count.positive?
        end
        return '' if summarized.empty?

        counts = summarized.map { |criterion, count| "#{header(criterion, count)}." }.join("\n")
        "#{counts}\n\nRun with #{detail_env_var}=true to see the uncovered #{noun_list(summarized.map(&:first))}."
      end

      # The "N lines are not covered by tests" header for a criterion
      # @param criterion [Symbol]
      # @param count [Integer]
      # @return [String]
      def header(criterion, count)
        singular, plural = CRITERION_LABELS.fetch(criterion)
        "#{count} #{pluralize(count, "#{singular} is", "#{plural} are")} not covered by tests"
      end

      # The formatted, uncovered items for a single criterion, across all files
      # @param criterion [Symbol]
      # @return [Array<String>]
      def uncovered_items(criterion)
        result.files.flat_map { |file| items_for(file, criterion) }
      end

      # The count of uncovered items for a single criterion across all files
      #
      # @param criterion [Symbol]
      # @return [Integer]
      def uncovered_count(criterion)
        result.files.sum { |file| count_for(file, criterion) }
      end

      # The formatted, uncovered items of one criterion within a single file
      # @param file [SimpleCov::SourceFile]
      # @param criterion [Symbol]
      # @return [Array<String>]
      def items_for(file, criterion) = send(:"#{criterion}_items", file)

      # The count of uncovered items of one criterion within a single file
      # @param file [SimpleCov::SourceFile]
      # @param criterion [Symbol]
      # @return [Integer]
      def count_for(file, criterion) = send(:"#{criterion}_count", file)

      # The formatted, uncovered lines within a single file
      # @param file [SimpleCov::SourceFile]
      # @return [Array<String>]
      def line_items(file) = file.missed_lines.map { |line| "#{project_path(file)}:#{line.number}" }

      # The formatted, uncovered branches within a single file
      # @param file [SimpleCov::SourceFile]
      # @return [Array<String>]
      def branch_items(file) = file.missed_branches.map { |branch| branch_text(file, branch) }

      # The formatted, uncovered methods within a single file
      # @param file [SimpleCov::SourceFile]
      # @return [Array<String>]
      def method_items(file)
        file.missed_methods.map { |method| "#{project_path(file)}:#{method.start_line} #{method}" }
      end

      # The count of uncovered lines within a single file
      # @param file [SimpleCov::SourceFile]
      # @return [Integer]
      def line_count(file) = file.missed_lines.count

      # The count of uncovered branches within a single file
      # @param file [SimpleCov::SourceFile]
      # @return [Integer]
      def branch_count(file) = file.missed_branches.count

      # The count of uncovered methods within a single file
      # @param file [SimpleCov::SourceFile]
      # @return [Integer]
      def method_count(file) = file.missed_methods.count

      # A single formatted, uncovered branch
      # @param file [SimpleCov::SourceFile]
      # @param branch [SimpleCov::SourceFile::Branch]
      # @return [String]
      def branch_text(file, branch) = "#{project_path(file)}:#{branch.report_line} (#{branch.type} branch)"

      # The path to a source file, relative to the project root
      # @param file [SimpleCov::SourceFile]
      # @return [String]
      def project_path(file) = File.join('.', file.project_filename)

      # Join plural nouns into a friendly list, e.g. "lines and branches"
      # @param criteria_list [Array<Symbol>]
      # @return [String]
      def noun_list(criteria_list)
        nouns = criteria_list.map { |criterion| CRITERION_LABELS.fetch(criterion).last }
        return nouns.first if nouns.size == 1

        "#{nouns[0..-2].join(', ')} and #{nouns.last}"
      end

      # Return the singular or plural form of a word based on the count
      # @param count [Integer] the count
      # @param singular [String] the singular form of the phrase
      # @param plural [String] the plural form of the phrase
      # @return [String]
      def pluralize(count, singular, plural) = count == 1 ? singular : plural
    end
  end
end
