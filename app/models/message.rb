class Message
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :channel, type: String
  field :channel_name, type: String
  field :ts, type: String
  index({ channel: 1, ts: 1 }, { unique: true })

  def username
    case self['username']
    when nil
      owner.try(:name_or_display_name)
    when /<@[^|]+|([^>]+)>/
      self['username'].match(/\|([^>]+)/)[1].to_s
    else
      self['username']
    end
  end

  def owner
    return User.find_by(uid: self['user']) if self['user']

    nil
  end

  def me?
    self['subtype'] == 'me_message'
  end

  def created_at
    Time.zone.at(ts.to_i)
  end
end
