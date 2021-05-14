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
            if value =~ /\Aalias:(.+)\z/
              list[key] = list[$1]
            end
          end
        end
      end
    end
  end
end
