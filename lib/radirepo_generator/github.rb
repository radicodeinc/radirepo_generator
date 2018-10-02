module RadirepoGenerator
  class Github
    def initialize(client)
      @client = client
      @login = client.login
    end

    def events_with_grouping(from, to, &block)
      @client.user_events(@login).each.with_object({}) { |event, memo|
        if event && aggressives.include?(event.type)
          if from <= event.created_at.localtime.to_date && event.created_at.localtime.to_date <= to
            next if ignore_repositories.include?(event.repo.name)
            memo[event.repo.name] ||= []
            memo[event.repo.name] << event
          end
        end
      }.each do |repo, events|
        block.call(repo, events) if block
      end
    end

    def yesterday_todo
        result = @client.search_issues("repo:radicodeinc/daily_report assignee:#{@client.user.login} sort:created-desc")
        return nil unless result.items.first
        issue = @client.issue("radicodeinc/daily_report", result.items.first.number)
        start = false
        fin = false
        todo = []
        issue.body.each_line do |line|
          if start | fin
            fin = line.match(/^##\s/)
            break if fin
            todo << line.gsub(/(\r\n|\r)/, "\n")
            next
          end
          start = line.include?('## 明日の作業予定')
        end

        todo.join(nil).chomp!
    end

    private

    def aggressives
      %w(
        IssuesEvent
        PullRequestEvent
        PullRequestReviewCommentEvent
        IssueCommentEvent
        CommitCommentEvent
      )
    end

    def ignore_repositories
      %w(
        radicodeinc/daily_report
      )
    end
  end
end

