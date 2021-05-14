class SummaryDecorator < Draper::Decorator
  delegate_all
  include DecorateSerializer

  attr :id, :title, :description, :path

  # rubocop:disable Lint/DuplicateMethods
  def id
    object._id.to_s
  end
  # rubocop:enable Lint/DuplicateMethods

  def path
    h.summary_path(self)
  end

  def description_html
    return '' unless object.description

    safe_html = h.html_escape(object.description.to_s)
    h.simple_format(safe_html)
  rescue StandardError => e
    Rails.logger.error "#{e.inspect} - #{e.backtrace}"
    object.description.to_s
  end

  def messages
    MessageDecorator.decorate_collection(object.sorted_messages)
  end
end
