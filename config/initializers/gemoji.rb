begin
  [
    { target: 'thinking', aliases: ['thinking_face'] }
  ].each do |item|
    emoji = Emoji.find_by_alias(item[:target])
    raise "emoji: #{item[:target]} is not defined" unless emoji

    Emoji.edit_emoji(emoji) do |char|
      item[:aliases].each do |alias_name|
        char.add_alias(alias_name)
      end
    end
  end
end
