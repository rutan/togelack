module SlackSupport
  # SlackのArchiveページのURLを扱う
  class ArchiveURL
    # init
    # @param [String] url
    def initialize(url)
      @url = url.to_s.strip
      extract_from_url
    end

    attr_reader :url, :team, :channel, :ts, :thread_ts

    def valid?
      channel
    end

    private

    def extract_from_url
      uri_object = URI.parse(@url)
      extract_team(uri_object)
      extract_channel_and_ts(uri_object)
      extract_thread_id(uri_object)
    end

    def extract_team(uri_object)
      match = uri_object.host.match(/\A([^.]+)\.slack\.com\z/)
      @team = match ? match[1] : ''
    end

    def extract_channel_and_ts(uri_object)
      match = uri_object.path.match(%r{\A/archives/(?<channel>[^/]+)/p(?<ts1>\d+)(?<ts2>\d{6})\z})
      return unless match

      @channel = match['channel']
      @ts = "#{match['ts1']}.#{match['ts2']}"
    end

    def extract_thread_id(uri_object)
      return if uri_object.query.blank?

      params = URI.decode_www_form(uri_object.query).to_h
      @thread_ts = params['thread_ts']
    end
  end
end
