class MessageDecorator < Draper::Decorator
  delegate_all
  include DecorateSerializer
  attr :id, :username, :channel, :channel_name, :text, :format_text, :avatar_url, :me?, :created_at, :created_time,
       :permalink

  # rubocop:disable Lint/DuplicateMethods
  def id
    object._id.to_s
  end
  # rubocop:enable Lint/DuplicateMethods

  def channel_name
    object.channel_name || object.channel
  end

  def created_time
    I18n.l(object.created_at)
  end

  def avatar_url
    if object['icons']
      if object['icons']['emoji']
        name = object['icons']['emoji'].gsub(':', '')
        self.class.emoji[name]
      else
        object['icons'].values.first
      end
    else
      object.owner.try(:avatar_url)
    end
  end

  def permalink
    "https://#{ENV['SLACK_TEAM_NAME']}.slack.com/archives/#{channel}/p#{object['ts'].to_s.gsub('.', '')}"
  end

  def format_text
    self.class.processor.call(object.text, self.class.context)[:output].to_s.html_safe
  end

  def attachment_items
    (object['attachments'] || []).map do |attachment|
      convert_attachment(attachment)
    end.compact
  end

  def convert_attachment(attachment)
    case attachment['service_name']
    when 'twitter'
      attachment
    when nil # 指定なし(通常テキスト)
      if attachment[:title] || attachment[:text]
        attachment
      elsif attachment[:image_url]
        attachment[:service_name] = 'togelack-image'
        attachment
      end
    end
  end

  def image
    object['file'] if object['file'] && object['file']['mimetype'].include?('image')
  end

  class << self
    def processor
      @processor ||= SlackMarkdown::Processor.new(
        asset_root: '/assets',
        cushion_link: ENV['CUSHION_LINK']
      )
    end

    def context
      @context ||= {
        original_emoji_set: emoji.list,
        on_slack_user_id: method(:on_slack_user_id),
        on_slack_user_name: method(:on_slack_user_name),
        on_slack_channel_id: method(:on_slack_channel_id)
      }
    end

    def on_slack_user_id(uid)
      Rails.cache.fetch("user_data_#{uid}", expires_in: 1.hours) do
        user = User.find_or_fetch(slack_client, uid)
        user ? { text: user.name, url: "/@#{user.name}" } : nil
      end
    end

    def on_slack_user_name(name)
      Rails.cache.fetch("user_data_#{name}", expires_in: 1.hours) do
        user = User.where(name: name).first
        user ? { text: user.name, url: "/@#{user.name}" } : nil
      end
    end

    def on_slack_channel_id(uid)
      Rails.cache.fetch("channel_data_#{uid}", expires_in: 1.hours) do
        resp = slack_client.conversations_info(channel: uid)
        if resp['ok']
          name = resp['channel']['name']
          { text: name, url: "https://#{ENV['SLACK_TEAM_NAME']}.slack.com/archives/#{uid}" }
        else
          { text: uid, url: '#' }
        end
      end
    end

    def emoji
      @emoji ||= SlackSupport::Emoji.new(slack_client)
    end

    def slack_client
      @slack_client ||= SlackSupport::Client.create
    end
  end
end
