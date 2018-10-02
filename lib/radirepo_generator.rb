ENV['TZ'] = 'Asia/Tokyo'

require 'active_support'
require 'active_support/core_ext'
require './lib/radirepo_generator/core_ext/string'
require 'octokit'
require 'erb'
require './lib/radirepo_generator/configurable'



Time.zone = 'Asia/Tokyo'

require './lib/radirepo_generator/generator'
require './lib/radirepo_generator/github'


module RadirepoGenerator
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

    def github_username
      gh_client.user.login
    end

    def username
      Pit.get('radirepo_generator', require: {
          'username' => "分かりやすい日本語名(例: 小寺)"
      })['username']
    end

    def result(erb, reports)
      erb.result(binding)
    end
  end
end

