module SummariesHelper
  def messages_json(summary)
    summary.sorted_messages.to_a.map { |n|
      MessageDecorator.new(n)
    }.to_json(root: false)
  end

  def attachment_text_format(text)
    MessageDecorator.new(OpenStruct.new(text: text)).format_text
  end
end
