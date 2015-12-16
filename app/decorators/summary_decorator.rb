class SummaryDecorator < Draper::Decorator
  delegate_all
  include DecorateSerializer
  attr :id, :title, :description, :path

  def id
    object._id.to_s
  end

  def path
    h.summary_path(self)
  end

  def description_html
    return '' unless object.description
    safe_html = h.html_escape(object.description.to_s)
    safe_html.gsub!(/https?:\/\/[^\s]+/) do |match|
      "<a href=\"https://slack-redir.net/link?url=#{h.html_escape match.to_s}\">#{match}</a>"
    end
    h.simple_format(safe_html)
  rescue => e
    Rails.logger.error "#{e.inspect} - #{e.backtrace}"
    object.description.to_s
  end

  def messages
    MessageDecorator.decorate_collection(object.sorted_messages)
  end
end
