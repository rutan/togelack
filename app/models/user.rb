class User
  include Mongoid::Document
  field :uid, type: String
  field :name, type: String
  field :avatar_url, type: String
  field :is_admin, type: Boolean
  field :last_fetched_at, type: DateTime
  has_many :summaries
  index({ uid: 1 }, {})
  index({ name: 1 }, {})

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

    User.create(
      uid: raw['id'],
      name: raw['name'],
      avatar_url: raw['profile']['image_192'],
      is_admin: raw['is_admin'],
      last_fetched_at: Time.now
    )
  end

  def fetch(client)
    raw = client.users_info(user: uid)['user']
    return unless raw

    update(
      name: raw['name'],
      avatar_url: raw['profile']['image_192'],
      is_admin: raw['is_admin'],
      last_fetched_at: Time.now
    )
  end

  def admin?
    !!is_admin
  end

  def to_param
    name
  end
end
