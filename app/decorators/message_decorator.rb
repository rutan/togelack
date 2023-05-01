require 'gemoji'

class MessageDecorator < Draper::Decorator
  delegate_all
  include DecorateSerializer
  attr :id, :username, :channel, :channel_name, :text, :format_text, :avatar_url, :me?, :created_at, :created_time,
       :permalink, :attachment_items, :is_bot, :reactions

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

  # rubocop:disable Naming/PredicateName
  def is_bot
    return true unless object.owner

    !!object.owner.try(:is_bot)
  end

  # rubocop:enable Naming/PredicateName

  def avatar_url
    icons = object['icons']

    return object.owner.try(:avatar_url) unless icons
    return icons.values.first unless icons['emoji']
    return icons['image_64'] if icons['image_64']

    name = icons['emoji'].gsub(':', '')
    self.class.emoji[name]
  end

  def permalink
    "https://#{ENV.fetch('SLACK_TEAM_NAME', nil)}.slack.com/archives/#{channel}/p#{object['ts'].to_s.gsub('.', '')}"
  end

  def format_text
    @format_text ||= self.class.processor.call(object.text, self.class.context)[:output].to_s.html_safe
  end

  def attachment_items
    @attachment_items ||=
      begin
        items = []

        items += (object['files'] || []).map do |file|
          convert_file(file)
        end

        items += (object['attachments'] || []).map do |attachment|
          convert_attachment(attachment)
        end

        items.compact
      end
  end

  def convert_file(file)
    {
      fallback: file['name'],
      title: file['title'],
      title_link: file['thumb_360'] || file['url_private']
    }
  end

  def convert_attachment(attachment)
    case attachment['service_name']
    when 'twitter'
      attachment
    else
      # 未知のサービスすべて（URL展開など）
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

  def reactions
    return [] if object['reactions'].blank?

    object['reactions'].map do |reaction|
      name = reaction['name'].to_s
      {
        name: name,
        count: reaction['count'].to_i,
        emoji_url: self.class.emoji[name],
        emoji_raw: Emoji.find_by_alias(name)&.raw
      }.with_indifferent_access
    end
  end

  class << self
    def processor
      @processor ||=
        begin
          processor = SlackMarkdown::Processor.new(
            asset_root: '/assets',
            cushion_link: ENV.fetch('CUSHION_LINK', nil)
          )
          processor.filters.push(::PipelineFilters::ReplaceEmojiFilter)
          processor.filters.push(::PipelineFilters::AddRelToLinkFilter)

          processor
        end
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
      Rails.cache.fetch("user_data_#{uid}", expires_in: 1.hour) do
        user = User.find_or_fetch(slack_client, uid)
        user ? { text: user.name, url: "/@#{user.name}" } : nil
      end
    end

    def on_slack_user_name(name)
      Rails.cache.fetch("user_data_#{name}", expires_in: 1.hour) do
        user = User.where(name: name).first
        user ? { text: user.name, url: "/@#{user.name}" } : nil
      end
    end

    def on_slack_channel_id(uid)
      Rails.cache.fetch("channel_data_#{uid}", expires_in: 1.hour) do
        resp = slack_client.conversations_info(channel: uid)
        if resp['ok']
          name = resp['channel']['name']
          { text: name, url: "https://#{ENV.fetch('SLACK_TEAM_NAME', nil)}.slack.com/archives/#{uid}" }
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
