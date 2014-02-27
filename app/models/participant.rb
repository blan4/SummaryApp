class Participant
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :email, type: String
  field :name, type: String
  field :surname, type: String
  #meta fields which will be added dynamicaly
  
  field :was, type: Boolean, default: true
  embedded_in :event, inverse_of: :participants
  embeds_many :categories

  scope :fake,-> {where(was: false)}
  scope :real,-> {where(was: true)}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, 
    presence: true,
    format: { with: VALID_EMAIL_REGEX }, 
    length: { maximum: 100 }, 
    uniqueness: { case_sensitive: false }
  validates :name,
    length: { maximum: 50 }, 
    presence: true
  validates :surname,
    length: { maximum: 50 }, 
    presence: true

  before_save { self.email = email.downcase }

  def gravatar(size)
    size ||= 50
    email_digest = Digest::MD5.hexdigest(id)
    "http://www.gravatar.com/avatar/#{email_digest}?size=#{size}&d=https://identicons.github.com/#{email_digest}.png"
  end

  def event_id
    event.id
  end

  def to_param
    URI.escape Base64.encode64(email)
  end

  def self.find_by_params(params)
    params = URI.unescape Base64.decode64(params)
    self.find_by email: params
  end

end