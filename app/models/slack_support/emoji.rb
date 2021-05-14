module SlackSupport
  class Emoji
    def initialize(client)
      @client = client
    end

    def get(name)
      list[name]
    end

    alias [] get

    def list
      @list ||= Rails.cache.fetch('slack_support__emoji#list', expires_in: 30.minutes) do
        resp = @client.emoji_list
        return {} unless resp['ok']

        resp['emoji'].tap do |list|
          list.map do |key, value|
            list[key] = list[Regexp.last_match(1)] if value =~ /\Aalias:(.+)\z/
          end
        end
      end
    end
  end
end
