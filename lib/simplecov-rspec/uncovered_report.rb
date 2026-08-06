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
      # @param files [Array<String>, nil] absolute paths to report on, or nil for every file
      # @example
      #   UncoveredReport.new(result: SimpleCov.result, criteria: [:line], detail: true, detail_env_var: 'X')
      def initialize(result:, criteria:, detail:, detail_env_var:, files: nil)
        @result = result
        @criteria = criteria
        @detail = detail
        @detail_env_var = detail_env_var
        @files = files
      end

      # The formatted report text, or an empty string if there is nothing to report
      #
      # A scoped report (one where `files` is not nil) always produces text, even when
      # every file it covers is fully covered. Silence there would be indistinguishable
      # from a clean run of the whole suite, which is the opposite of what asking for a
      # scope means.
      #
      # @return [String]
      def to_s = files.nil? ? uncovered_text : scoped_text

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

      # The absolute paths to report on, or nil to report on every file in the result
      # @return [Array<String>, nil]
      # @api private
      attr_reader :files

      # The result's files, narrowed to `files` when a scope was given
      # @return [Array<SimpleCov::SourceFile>]
      def reported_files
        @reported_files ||= files.nil? ? result.files : result.files.select { |file| files.include?(file.filename) }
      end

      # The uncovered items or counts, in the requested level of detail
      # @return [String]
      def uncovered_text = detail ? detailed_text : summary_text

      # The report for a scope, which is always non-empty
      #
      # Names how much of the result the scope covered, then one section per criterion,
      # then a closing statement.
      #
      # @return [String]
      def scoped_text
        return "#{scope_text}\n\n#{nothing_reported_text}" if reported_files.empty?

        [scope_text, *criterion_blocks, closing_text].compact.join("\n\n")
      end

      # Why a scope produced nothing to report on
      #
      # Three different mistakes end up here, and only one of them is "your pattern
      # matched nothing". Saying that when the pattern matched a real file that
      # SimpleCov never saw sends the reader looking for a typo that isn't there.
      #
      # @return [String]
      def nothing_reported_text
        return 'No files were requested, so no coverage was reported.' if files.empty?
        return 'No files matched, so no coverage was reported.' if matched_files.empty?

        untracked_text
      end

      # The requested paths that name a file on disk
      #
      # A pattern that globbed successfully expands to paths that exist; one that
      # matched nothing is kept as a literal path that does not.
      #
      # @return [Array<String>]
      def matched_files = @matched_files ||= files.select { |path| File.file?(path) }

      # The report for files that exist but are absent from the coverage result
      # @return [String]
      def untracked_text
        count = matched_files.count
        "#{count} #{pluralize(count, 'file matched, but it is not', 'files matched, but none are')} in the " \
          "coverage result. #{pluralize(count, 'It', 'They')} may not have been loaded by this run, or may " \
          'be excluded by a SimpleCov filter.'
      end

      # The line stating how much of the result the scope covered
      #
      # Reported alongside the total so that a scoped report showing nothing uncovered
      # cannot be misread as the whole suite being fully covered. Marked off as a section
      # header because SimpleCov prints its own project-wide summary just above, on the
      # same stream, counting different things.
      #
      # @return [String]
      def scope_text
        "-- Reporting uncovered #{noun_list(criteria)} for " \
          "#{reported_files.count} of #{result.files.count} #{pluralize(result.files.count, 'file', 'files')} --"
      end

      # The body of a scoped report: what the files cover, then what they miss
      #
      # A criterion's coverage sits directly above its own listing, and criteria with
      # nothing to list share a block, so that a blank line always means "next criterion"
      # and never separates a heading from what it heads.
      #
      # @return [Array<String>]
      def criterion_blocks
        criteria.map { |criterion| [coverage_text(criterion), missing_text(criterion)] }
                .chunk_while { |(_, missing), (_, next_missing)| missing.nil? && next_missing.nil? }
                .map { |block| block.flatten.compact.join("\n") }
      end

      # A criterion's coverage across the scoped files
      #
      # Deliberately not labelled the way SimpleCov labels its own project-wide summary.
      # The two appear within a few lines of each other and count different things, so
      # sharing a label would make the narrower number look like a restatement of the
      # broader one.
      #
      # @param criterion [Symbol]
      # @return [String]
      def coverage_text(criterion)
        covered = covered_count(criterion)
        total = covered + uncovered_count(criterion)
        "Scoped #{criterion} coverage: #{covered} / #{total} (#{percent_text(covered, total)})"
      end

      # A covered-of-total ratio, formatted the way SimpleCov formats its own
      #
      # Truncated rather than rounded, through SimpleCov's own helper, because its
      # project-wide summary prints a few lines above this one over the same kind of
      # ratio. Two percentages differing in the last digit would read as a bug in one of
      # them. A criterion with nothing to cover is 100%, which is also what SimpleCov says.
      #
      # @param covered [Integer] the number of covered items
      # @param total [Integer] the number of items that could be covered
      #
      # @return [String]
      def percent_text(covered, total)
        percent = total.zero? ? 100.0 : covered * 100.0 / total
        "#{format('%.2f', ::SimpleCov.round_coverage(percent))}%"
      end

      # A criterion's uncovered items or count
      #
      # Nil when the scoped files leave nothing uncovered for it.
      #
      # @param criterion [Symbol]
      # @return [String, nil]
      def missing_text(criterion)
        return section(criterion) if detail

        count = uncovered_count(criterion)
        count.positive? ? "#{header(criterion, count)}." : nil
      end

      # The closing statement: that nothing is uncovered, or how to see what is
      # @return [String, nil]
      def closing_text
        return nothing_uncovered_text if missing_criteria.empty?
        return nil if detail

        "Run with #{detail_env_var}=true to see the uncovered #{noun_list(missing_criteria)}."
      end

      # The criteria the scoped files leave something uncovered for
      # @return [Array<Symbol>]
      def missing_criteria = criteria.reject { |criterion| uncovered_count(criterion).zero? }

      # The statement that a scope turned up no uncovered items
      # @return [String]
      def nothing_uncovered_text
        "No uncovered #{noun_list(criteria)} in #{pluralize(reported_files.count, 'this file', 'these files')}."
      end

      # The count of covered items for a single criterion across the reported files
      # @param criterion [Symbol]
      # @return [Integer]
      def covered_count(criterion)
        plural = CRITERION_LABELS.fetch(criterion).last
        reported_files.sum { |file| file.public_send(:"covered_#{plural}").count }
      end

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
        reported_files.flat_map { |file| items_for(file, criterion) }
      end

      # The count of uncovered items for a single criterion across all files
      #
      # @param criterion [Symbol]
      # @return [Integer]
      def uncovered_count(criterion)
        reported_files.sum { |file| count_for(file, criterion) }
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
