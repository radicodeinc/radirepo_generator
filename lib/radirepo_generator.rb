ENV['TZ'] = 'Asia/Tokyo'

require 'active_support'
require 'active_support/core_ext'
require 'radirepo_generator/core_ext/string'
require 'octokit'
require 'erb'
require 'radirepo_generator/configurable'



Time.zone = 'Asia/Tokyo'

require 'radirepo_generator/generator'
require 'radirepo_generator/github'


module RadirepoGenerator
  class << self  
    def gh_client
      Octokit::Client.new Configurable.github_octokit_options
    end

    def ghe_client
      Octokit::Client.new Configurable.github_enterprise_octokit_options
    end

    def events_with_grouping(gh: true, ghe: true, from: nil, to: nil, ignore_repositories: [], &block)
      events = []

      if gh
        gh_events = Github.new(gh_client).events_with_grouping(from, to, ignore_repositories, &block)
        events.concat gh_events if gh_events.is_a?(Array)
      end

      if ghe
        ghe_events = Github.new(ghe_client).events_with_grouping(from, to, ignore_repositories, &block)
        events.concat ghe_events if ghe_events.is_a?(Array)
      end

      events
    end

    def result(erb, reports)
      erb.result(binding)
    end

    def github_events_text(gh:, ghe:, from:, to:)
      github_events = ''
      ignore_repositories = Configurable.ignore_repositories
      events_with_grouping(gh: gh, ghe: ghe, from: from, to: to, ignore_repositories: ignore_repositories) do |repo, events|
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
      github_events
    end

    def upsert_github_today_issue(options)
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
      github_events = github_events_text(gh: options[:gh], ghe: options[:ghe], from: from, to: to)

      reports = {
          yesterday_todo: Github.new(gh_client).yesterday_todo,
          github_events_title: github_events_title,
          github_events: github_events
      }
      template = File.read(File.expand_path("../../templates/template.md.erb", __FILE__))
      erb = ERB.new(template, 0, '%-')
      body = RadirepoGenerator.result(erb, reports)
      title = "#{Time.now.strftime("日報_%Y%m%d #{Configurable.username}")}"
      body = body.gsub(/\n/, "\r")
      issues = Github.new(gh_client).find_same_title_issue(title)
      title = "wip #{title}"
      issue = if issues.first
                 issue = Github.new(gh_client).daily_report_issue(issues.first.number)
                 body = issue.body.gsub(/##[^\r\n]*?Github作業記録\r\n.+?(\r\n##|$)/m, "## #{github_events_title}\r\n#{github_events}")
                 Github.new(gh_client).update_issue_body( issues.first.number, body)
                      else
                  Github.new(gh_client).create_issue(title: title, body: body, assignee: gh_client.user.login, labels: 'daily report')
                     end
      issue
    end
  end
end

