module Fastlane
  module Actions
    class FindCommitsAction < Action
      def self.run(params)
        regex = Regexp.new(params[:matching])
        changelog = log(from: params[:from], to: params[:to], pretty: params[:pretty])

        if changelog.to_s.empty?
          UI.important('No issues found.')
          return []
        end

        tickets = tickets(log: changelog, regex: regex)
        UI.important("Additional Issues: #{tickets.join("\n")}")
        return tickets
      end

      #####################################################
      # @!group Helpers
      #####################################################

      def self.log(from:, to:, pretty:)
        if to.to_s.empty? || from.to_s.empty?
          UI.important('Git Tickets: log(to:, from:) cannot be nil')
          return nil
        end

        other_action.changelog_from_git_commits(
          between: [from, to],
          pretty: pretty,
          merge_commit_filtering: :exclude_merges.to_s
        )
      end

      def self.tickets(log:, regex:)
        return [] if log.to_s.empty?

        log.each_line
           .map(&:strip)
           .grep(regex)
           .flatten
           .reject(&:empty?)
           .uniq
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.details
        'Extracts additional issues from the log'
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.output
        [String]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :from,
            env_name: 'FL_FIND_COMMITS_FROM',
            description:  'start commit',
            optional: true,
            default_value: ENV['FL_FIND_TICKETS_FROM'] || 'HEAD'
          ),
          FastlaneCore::ConfigItem.new(
            key: :to,
            env_name: 'FL_FIND_COMMITS_TO',
            description:  'end commit',
            optional: true,
            default_value: ENV['FL_FIND_TICKETS_TO'] || ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT'] || 'HEAD'
          ),
          FastlaneCore::ConfigItem.new(
            key: :matching,
            env_name: 'FL_FIND_COMMITS_MATCHING',
            description:  'regex to only include to the change log',
            optional: true,
            default_value: ENV['FL_FIND_TICKETS_MATCHING'] || '([A-Z]+-\d+)'
          ),
          FastlaneCore::ConfigItem.new(
            key: :pretty,
            env_name: 'FL_FIND_COMMITS_PRETTY_FORMAT',
            description:  'git pretty format',
            optional: true,
            default_value: ENV['FL_FIND_TICKETS_PRETTY_FORMAT'] || '%s'
          )
        ]
      end

      def self.author
        'Syd Srirak <sydney.srirak@outware.com.au>'
      end
    end
  end
end
