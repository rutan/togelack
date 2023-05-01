module Services
  class CacheHistoryService
    def initialize(client)
      @client = client
      @cache_users = {}
      @cache_bots = {}
    end

    def cache(url)
      archive_url = SlackSupport::ArchiveURL.new(url)
      raise 'invalid url' unless archive_url.valid?

      c_id, = detect_channel_id_and_name(archive_url)
      raise 'not found channels' unless c_id

      if archive_url.thread_ts
        fetch_replies(archive_url)
      else
        fetch_histories(archive_url).reverse
      end
    end

    private

    def resolver
      @resolver ||= SlackSupport::ChannelResolver.new(@client)
    end

    def detect_channel_id_and_name(archive_url)
      [
        archive_url.channel,
        resolver.resolve_by_id(archive_url.channel)
      ]
    end

    def fetch_histories(archive_url)
      c_id, = detect_channel_id_and_name(archive_url)
      params = {
        channel: c_id,
        oldest: archive_url.ts,
        inclusive: true,
        limit: 30
      }
      resp = @client.conversations_history(params)['messages']
      resp ? resp.map { |n| convert_and_store_message(n, archive_url) } : []
    end

    def fetch_replies(archive_url)
      c_id, = detect_channel_id_and_name(archive_url)
      params = {
        channel: c_id,
        ts: archive_url.thread_ts,
        oldest: archive_url.ts,
        inclusive: false,
        limit: 30
      }
      resp = @client.conversations_replies(params)['messages']
      resp ? resp.map { |n| convert_and_store_message(n, archive_url) } : []
    end

    def convert_and_store_message(raw, archive_url)
      _, channel_name = detect_channel_id_and_name(archive_url)

      # bot
      raw['user'] = fetch_bot_user_id(raw['bot_id']) if !raw['user'] && raw['bot_id']

      # user
      prefetch_user(raw['user']) if raw['user']

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

    def prefetch_user(user_id)
      return if @cache_users.key?(user_id)

      @cache_users[user_id] = User.find_or_fetch(@client, user_id)
    end

    def fetch_bot_user_id(bot_id)
      @cache_bots[bot_id] = @client.bots_info(bot: bot_id) unless @cache_bots[bot_id]

      @cache_bots[bot_id]['ok'] ? @cache_bots[bot_id]['bot']['user_id'] : nil
    end
  end
end
