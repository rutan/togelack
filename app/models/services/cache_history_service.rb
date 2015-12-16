module Services
  class CacheHistoryService
    def initialize(client)
      @client = client
      @cache_users = {}
    end

    def cache(url)
      archive_url = SlackSupport::ArchiveURL.new(url)
      c_id = SlackSupport::ChannelResolver.new(@client).resolve(archive_url.channel)
      raise 'not found channels' unless c_id
      params = {
          channel: c_id,
          oldest: archive_url.ts,
          inclusive: false,
          count: 30,
      }
      raw_messages =
          case c_id.first
          when 'C'
            @client.channels_history(params)['messages'] || []
          when 'G'
            @client.groups_history(params)['messages'] || []
          when 'D'
            @client.im_history(params)['messages'] || []
          else
            []
          end
      raw_messages.map { |raw|
        # user
        if raw['user'] && !@cache_users.has_key?(raw['user'])
          @cache_users[raw['user']] = User.find_or_fetch(@client, raw['user'])
        end

        # message
        message = Message.find_or_initialize_by(channel: archive_url.channel, ts: raw['ts'])
        raw.each { |k, v| message[k] = v }
        message.save
        message
      }.reverse
    end
  end
end
