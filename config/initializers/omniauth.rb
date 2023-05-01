Rails.application.config.middleware.use OmniAuth::Builder do
  provider(:slack, ENV.fetch('SLACK_CLIENT_ID', nil), ENV.fetch('SLACK_CLIENT_SECRET', nil),
           scope: 'identify,read',
           team: ENV.fetch('SLACK_TEAM_ID', nil))
end
