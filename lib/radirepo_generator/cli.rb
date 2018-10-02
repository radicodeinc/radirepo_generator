require "./lib/radirepo_generator"
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
      from = Date.parse(options[:from])
      to   = Date.parse(options[:to])
      since = options[:since]

      diff = (to - from).to_i
      diff.zero? ? from -= since : since = diff

      period = case since
      when 999 then 'すべての'
      when 0 then "本日の"
      else "#{since + 1}日間の"
      end
      github_events_title = "#{period}Github作業記録"

      github_events = ''
      RadirepoGenerator.events_with_grouping(gh: options[:gh], ghe: options[:ghe], from: from, to: to) do |repo, events|
        github_events += "### #{repo}\n"

        events.sort_by(&:created_at).each_with_object({ keys: [] }) do |event, memo|
          payload_type = event.type.
          gsub('Event', '').
          gsub(/.*Comment/, 'Comment').
          gsub('Issues', 'Issue').
          underscore
          payload = event.payload.send(:"#{payload_type}")
          type = payload_type.dup

          title = case event.type
          when 'IssueCommentEvent'
            "#{payload.body.plain.cut} (#{event.payload.issue.title.cut(30)})"
          when 'CommitCommentEvent'
            payload.body.plain.cut
          when 'IssuesEvent'
            type = "#{event.payload.action}_#{type}"
            payload.title.plain.cut
          when 'PullRequestReviewCommentEvent'
            type = 'comment'
            if event.payload.pull_request.respond_to?(:title)
              "#{payload.body.plain.cut} (#{event.payload.pull_request.title.cut(30)})"
            else
              payload.body.plain.cut
            end
          when 'PullRequestEvent'
            "**#{payload.title.plain.cut}**"
          else
            payload.title.plain.cut
          end

          link = payload.html_url
          key = "#{type}-#{link}"

          next if memo[:keys].include?(key)
          memo[:keys] << key

          hour_and_minute = "#{event.created_at.strftime('%H:%M')}"
          github_events +=  "- `#{hour_and_minute}`[#{type}]: #{title}(#{link})\n"
        end
      end

      reports = {
          yesterday_todo: RadirepoGenerator.yesterday_todo,
          github_events_title: github_events_title,
          github_events: github_events
      }
      template = File.read("./templates/template.md.erb")
      erb = ERB.new(template, 0, '%-')
      body = RadirepoGenerator.result(erb, reports)
      title = "#{Time.now.strftime("日報_%Y%m%d #{RadirepoGenerator.username}")}"
      body = body.gsub(/\n/, "\r")
      url = "https://github.com/radicodeinc/daily_report/issues/new?"
      url += "assignee=#{RadirepoGenerator.github_username}&title=#{title}&body=#{CGI.escapeHTML(body)}&"
      url += "labels=daily report"

      Launchy.open(url)
    end
  end
end


