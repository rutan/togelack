module SlackSupport
  # SlackのArchiveページのURLを扱う
  class ArchiveURL
    # init
    # @param [String] url
    def initialize(url)
      self.url = url.to_s
      extract_from_url
    end

    attr_accessor :url, :team, :channel, :ts

    private

    def extract_from_url
      result = url.match URL_REGEX
      return nil unless result

      self.team = result['team']
      self.channel = result['channel']
      self.ts = "#{result['ts1']}.#{result['ts2']}"
    end

    URL_REGEX = Regexp.new('\\Ahttps://(?<team>[^\\.]+)\\.slack\\.com/archives/(?<channel>[^/]+)/p(?<ts1>\\d+)(?<ts2>\\d{6})\\z')
  end
end
