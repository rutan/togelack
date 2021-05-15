class User
  include Mongoid::Document
  field :uid, type: String
  field :name, type: String
  field :display_name, type: String
  field :avatar_url, type: String
  field :is_admin, type: Boolean
  field :is_bot, type: Boolean
  field :last_fetched_at, type: DateTime
  has_many :summaries
  index({ uid: 1 }, {})
  index({ name: 1 }, {})

  def name_or_display_name
    display_name.present? ? display_name : name
  end

  def self.find_or_fetch(client, uid)
    user = where(uid: uid).first
    if user
      user.fetch(client) unless user.last_fetched_at && user.last_fetched_at > 24.hours.ago
      user
    else
      fetch(client, uid)
    end
  end

  def self.fetch(client, uid)
    raw = client.users_info(user: uid)['user']
    return nil unless raw

    User.find_or_create_by(uid: raw['id']).update_by_raw(raw)
  end

  def fetch(client)
    raw = client.users_info(user: uid)['user']
    return unless raw

    update_by_raw(raw)
  end

  def admin?
    !!is_admin
  end

  def to_param
    name
  end

  def update_by_raw(raw)
    update(
      name: raw['name'],
      display_name: raw['profile']['display_name'],
      avatar_url: raw['profile']['image_192'],
      is_admin: raw['is_admin'],
      is_bot: (raw['is_bot'] || raw['is_app_user']),
      last_fetched_at: Time.zone.now
    )
    self
  end
end
