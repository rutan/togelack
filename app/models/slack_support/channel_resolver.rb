module SlackSupport
  class ChannelResolver
    def initialize(client)
      @client = client
      @cache = {}
    end

    def resolve_by_id(id)
      @cache[id] ||=
        begin
          response = @client.conversations_info({channel: id})
          response['ok'] ? response['channel']['name'] : id
        end
    end

    def resolve_by_name(name)
      name # :(
    end
  end
end
