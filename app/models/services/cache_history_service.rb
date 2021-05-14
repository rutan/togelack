module Services
  class CacheHistoryService
    def initialize(client)
      @client = client
      @cache_users = {}
    end

    def cache(url)
      archive_url = SlackSupport::ArchiveURL.new(url)
      c_id, = detect_channel_id_and_name(archive_url)
      raise 'not found channels' unless c_id

      fetch_messages(archive_url).map do |raw|
        convert_and_store_message(raw, archive_url)
      end.reverse
    end

    private

    def resolver
      @resolver ||= SlackSupport::ChannelResolver.new(@client)
    end

    def detect_channel_id_and_name(archive_url)
      if archive_url.channel.match(/[A-Z]/)
        [
          archive_url.channel,
          resolver.resolve_by_id(archive_url.channel)
        ]
      else
        [
          resolver.resolve_by_name(archive_url.channel),
          archive_url.channel
        ]
      end
    end

    def fetch_messages(archive_url)
      c_id, = detect_channel_id_and_name(archive_url)
      params = {
        channel: c_id,
        oldest: archive_url.ts,
        inclusive: false,
        count: 30
      }
      @client.conversations_history(params)['messages'] || []
    end

    def convert_and_store_message(raw, archive_url)
      _, channel_name = detect_channel_id_and_name(archive_url)

      # user
      if raw['user'] && !@cache_users.key?(raw['user'])
        @cache_users[raw['user']] = User.find_or_fetch(@client, raw['user'])
      end

      # message
      message = Message.find_or_initialize_by(
        channel: archive_url.channel,
        ts: raw['ts']
      )
      message['channel_name'] = channel_name
      raw.each { |k, v| message[k] = v }
      message.save

      message
    end
  end
end
