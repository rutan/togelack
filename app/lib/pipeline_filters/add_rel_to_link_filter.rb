module PipelineFilters
  class AddRelToLinkFilter < ::HTML::Pipeline::Filter
    def call
      doc.search('a').each do |node|
        next unless node['href'].starts_with?('http')
        next if node['rel']

        node['target'] = '_blank'
        node['rel'] = 'noopener noreferrer'
      end

      doc
    end
  end
end
