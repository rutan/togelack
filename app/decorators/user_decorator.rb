class UserDecorator < Draper::Decorator
  delegate_all
  include DecorateSerializer
  attr :id, :uid, :name, :avatar_url, :is_admin, :url

  # rubocop:disable Lint/DuplicateMethods
  def id
    object._id.to_s
  end
  # rubocop:enable Lint/DuplicateMethods

  def url
    h.user_path(object)
  end
end
