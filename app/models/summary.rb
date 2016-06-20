class Summary
  include Mongoid::Document
  paginates_per 5

  field :title, type: String
  field :description, type: String
  belongs_to :user
  has_and_belongs_to_many :messages

  scope :newest, -> { order(id: :desc) }

  validates :title,
            length: 1..64
  validates :description,
            length: 0..1048
  validates :messages,
            length: 1..1000

  after_initialize :set_default_params

  def sorted_messages
    ms = self.messages.to_a
    self.message_ids.map do |id|
      ms.select { |n| n.id == id }.first
    end
  end

  def self.match_text (text)
    message_ids = Message.any_of({ :text => /.*#{text}.*/ }).only(:_id).map do |v|
      {message_ids: v}
    end

    any_of({ :title => /.*#{text}.*/ }, message_ids)
  end

  private

  def set_default_params
    self.title ||= ''
    self.description ||= ''
  end
end
