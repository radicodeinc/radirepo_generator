ENV['TZ'] = 'Asia/Tokyo'

require 'active_support'
require 'active_support/core_ext'
require './lib/daily_report_generator/core_ext/string'
require 'octokit'
require 'erb'
require './lib/daily_report_generator/configurable'



Time.zone = 'Asia/Tokyo'

require './lib/daily_report_generator/generator'
require './lib/daily_report_generator/github'


module DailyReportGenerator
  class << self  
    def gh_client
      Octokit::Client.new Configurable.github_octokit_options
    end

    def ghe_client
      Octokit::Client.new Configurable.github_enterprise_octokit_options
    end

    def events_with_grouping(gh: true, ghe: true, from: nil, to: nil, &block)
      events = []

      if gh
        gh_events = Github.new(gh_client).events_with_grouping(from, to, &block)
        events.concat gh_events if gh_events.is_a?(Array)
      end

      if ghe
        ghe_events = Github.new(ghe_client).events_with_grouping(from, to, &block)
        events.concat ghe_events if ghe_events.is_a?(Array)
      end

      events
    end

    def yesterday_todo
        Github.new(gh_client).yesterday_todo
    end
  end
end

