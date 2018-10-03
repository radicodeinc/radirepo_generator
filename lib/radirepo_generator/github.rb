module RadirepoGenerator
  class Github
    def initialize(client)
      @client = client
      @login = client.login
    end

    def events_with_grouping(from, to, option_ignore_repositories = [], &block)
      ignore_repositories = option_ignore_repositories + default_ignore_repositories
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

    def update_issue_body(issue_number, body)
      @client.update_issue('radicodeinc/daily_report', issue_number, { body: body })
    end

    def create_issue(title:, body:, assignee: nil, labels: nil)
      option = {
          assignee: assignee,
          labels: labels
      }
      @client.create_issue('radicodeinc/daily_report', title, body, option)
    end

    def find_same_title_issue(title)
      q = " '#{title}' repo:radicodeinc/daily_report assignee:#{@client.user.login} state:open"
      result = @client.search_issues(q)
      result.items
    end

    def daily_report_issue(issue_number)
      @client.issue("radicodeinc/daily_report", issue_number)
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

    def default_ignore_repositories
      %w(
        radicodeinc/daily_report
      )
    end
  end
end

