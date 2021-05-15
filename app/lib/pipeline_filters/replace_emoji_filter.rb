require 'gemoji'

module PipelineFilters
  class ReplaceEmojiFilter < ::HTML::Pipeline::Filter
    def call
      doc.search('img').each do |node|
        next unless node['class'] == 'emoji'
        next if node['src'].starts_with?('https://')

        name = node['title'].gsub(':', '')
        info = Emoji.find_by_alias(name)

        node.replace(info.raw) if info
      end

      doc
    end
  end
end
