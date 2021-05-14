require 'slack-ruby-client'

module SlackSupport
  module Client
    def self.create(token = nil)
      Slack::Web::Client.new(token: (token || ENV['SLACK_TOKEN']))
    end
  end
end
