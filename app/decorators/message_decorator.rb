class MessageDecorator < Draper::Decorator
  delegate_all
  include DecorateSerializer
  attr :id, :username, :channel, :channel_name, :text, :format_text, :avatar_url, :me?, :created_at, :created_time, :permalink

  def id
    object._id.to_s
  end

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
    "https://#{ENV['SLACK_TEAM_NAME']}.slack.com/archives/#{self.channel}/p#{object['ts'].to_s.gsub('.', '')}"
  end

  def format_text
    self.class.processor.call(object.text, self.class.context)[:output].to_s.html_safe
  end

  def attachment_items
    (object['attachments'] || []).map { |attachment|
      case attachment['service_name']
      when 'twitter'
        attachment
      when nil # 指定なし(通常テキスト)
        if attachment[:title] || attachment[:text]
          if attachment[:title_link]
            attachment[:title_link] = "https://slack-redir.net/link?url=#{URI.encode attachment[:title_link]}"
          end
          attachment
        elsif attachment[:image_url]
          attachment[:service_name] = 'togelack-image'
          attachment
        else
          nil
        end
      end
    }.compact
  end

  def image
    if object['file'] && object['file']['mimetype'].include?('image')
      object['file']
    else
      nil
    end
  end

  def self.processor
    @prosessor ||= SlackMarkdown::Processor.new(
        asset_root: '/assets',
        cushion_link: 'https://slack-redir.net/link?url='
    )
  end

  def self.context
    @context ||= {
        original_emoji_set: self.emoji.list,
        on_slack_user_id: -> (uid) {
          Rails.cache.fetch("user_data_#{uid}", expires_in: 1.hours) do
            user = User.find_or_fetch(self.slack_client, uid)
            user ? {text: user.name, url: "/@#{user.name}"} : nil
          end
        },
        on_slack_user_name: -> (name) {
          Rails.cache.fetch("user_data_#{name}", expires_in: 1.hours) do
            user = User.where(name: name).first
            user ? {text: user.name, url: "/@#{user.name}"} : nil
          end
        },
        on_slack_channel_id: -> (uid) {
          Rails.cache.fetch("channel_data_#{uid}", expires_in: 1.hours) do
            case uid[0]
            when 'C'
              name = self.slack_client.channels_info(channel: uid)['channel']['name']
              {text: name, url: "https://#{ENV['SLACK_TEAM_NAME']}.slack.com/archives/#{name}"}
            when 'G'
              name = self.slack_client.groups_info(channel: uid)['group']['name']
              {text: name, url: "https://#{ENV['SLACK_TEAM_NAME']}.slack.com/archives/#{name}"}
            else
              {text: uid, url: nil}
            end
          end
        }
    }
  end

  def self.emoji
    @emoji ||= SlackSupport::Emoji.new(slack_client)
  end

  def self.slack_client
    @slack_client ||= SlackSupport::Client.create
  end
end
