module SlackSupport
  module Client
    def self.create(token = nil)
      Slack::Client.new(token: token || ENV['SLACK_TOKEN'])
    end
  end
end
