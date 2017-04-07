require 'erb'

module SlackSupport
  class Poster
    def initialize(client, channel_name)
      @client = client
      @channel_name = channel_name
    end

    def post(user, url, title, description)
      @client.chat_postMessage({
                                   channel: channel_id,
                                   username: 'togelack',
                                   text: "<@#{user.uid}> が『<#{url}|#{ERB::Util.html_escape title}>』についてまとめました。\n<#{ERB::Util.html_escape url}>",
                                   parse: 'none',
                                   unfurl_links: true,
                                   icon_url: icon.match(/\Ahttp/) ? icon : nil,
                                   icon_emoji: icon.match(/\A:.+:\z/) ? icon : nil,
                                   attachments: [
                                       {
                                           fallback: title,
                                           author_name: "@#{user.name}",
                                           author_icon: user.avatar_url,
                                           color: '#7CD197',
                                           title: title,
                                           title_link: url,
                                           text: description,
                                       }
                                   ].to_json,
                               }.delete_if { |_, v| v.nil? })
    end

    private

    def channel_id
      @channel_id ||= ChannelResolver.new(@client).resolve_by_name(@channel_name)
    end

    def icon
      (ENV['SLACK_ICON'] || ':slack:').to_s
    end
  end
end
