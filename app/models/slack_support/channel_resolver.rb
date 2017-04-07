module SlackSupport
  class ChannelResolver
    def initialize(client)
      @client = client
    end

    def resolve_by_id(id)
      channel =
        channels.find { |c| c['id'] == id } ||
        groups.find { |c| c['id'] == id }
      channel ? channel['name'] : id
    end

    def resolve_by_name(name)
      channel =
        channels.find { |c| c['name'] == name } ||
          groups.find { |c| c['name'] == name }
      channel ? channel['id'] : name
    end

    private

    def channels
      unless @channels
        response = @client.channels_list
        raise 'missing connect to slack' unless response['ok']
        @channels = response['channels']
      end
      @channels
    end

    def groups
      unless @groups
        response = @client.groups_list
        raise 'missing connect to slack' unless response['ok']
        @groups = response['groups']
      end
      @groups
    end
  end
end
