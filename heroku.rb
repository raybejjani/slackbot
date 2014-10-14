
require 'chat-adapter'

class HerokuSlackAdapter < ChatAdapter::Slack
  def initialize(options)
    super(nick: options.fetch(:nick),
      webhook_token: ENV['SLACK_WEBHOOK_TOKEN'],
      api_token: ENV['SLACK_API_TOKEN'],
      icon_emoji: options.fetch(:icon_emoji))
  end
end