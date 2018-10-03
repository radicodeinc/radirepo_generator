require "radirepo_generator"
require 'thor'
require 'launchy'

module RadirepoGenerator
  class Cli < Thor
    desc 'pulls', 'show pull requests'
    method_option :gh, type: :boolean, aliases: '-g', default: true
    method_option :ghe, type: :boolean, aliases: '-l'
    method_option :start_date, type: :string, aliases: '-s'
    method_option :end_date, type: :string, aliases: '-e'
    def pulls
      start_date = Date.parse(options[:start_date]) if options[:start_date]
      end_date = Date.parse(options[:end_date]) if options[:end_date]

      puts "Pull Requests#{" (#{start_date}...#{end_date})" if start_date && end_date}"
      puts '-'
      puts ''

      Furik.pull_requests(gh: options[:gh], ghe: options[:ghe]) do |repo, issues|
        if issues && !issues.empty?
          string_issues = issues.each.with_object('') do |issue, memo|
            date = issue.created_at.localtime.to_date

            next if start_date && date < start_date
            next if end_date && date > end_date

            memo << "- [#{issue.title}](#{issue.html_url}):"
            memo << " (#{issue.body.plain.cut})" if issue.body && !issue.body.empty?
            memo << " #{issue.created_at.localtime.to_date}\n"
          end

          unless string_issues == ''
            puts "### #{repo}"
            puts ''
            puts string_issues
            puts ''
          end
        end
      end
    end

    desc 'activity', 'show activity'
    method_option :gh, type: :boolean, aliases: '-g', default: true
    method_option :ghe, type: :boolean, aliases: '-l'
    method_option :since, type: :numeric, aliases: '-d', default: 0
    method_option :from, type: :string, aliases: '-f', default: Date.today.to_s
    method_option :to, type: :string, aliases: '-t', default: Date.today.to_s
    def activity
      issue = RadirepoGenerator.upsert_github_today_issue(options)
      puts issue.title
      puts issue.body

      url = "https://github.com/radicodeinc/daily_report/issues/#{issue.number}"
      Launchy.open(url)
    end
  end
end


