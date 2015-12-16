module SlackSupport
  # チャンネル名からIDを逆引き
  class ChannelResolver
    def initialize(client)
      @client = client
    end

    def resolve(name)
      channels[name] || groups[name] || name
    end

    private

    def channels
      unless @channels
        response = @client.channels_list
        raise 'missing connect to slack' unless response['ok']
        array = response['channels'].map { |n| [n['name'], n['id']] }
        @channels = Hash[array]
      end
      @channels
    end

    def groups
      unless @groups
        response = @client.groups_list
        raise 'missing connect to slack' unless response['ok']
        array = response['groups'].map {|n| [n['name'], n['id']]}
        @groups = Hash[array]
      end
      @groups
    end
  end
end
