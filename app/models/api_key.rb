class ApiKey < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :assign_token, on: :create

  def self.normalize_token(token)
    token.to_s.slice(0, 64)
  end

  private

  def assign_token
    while token.blank? || self.class.exists?(token: token)
      self.token = SecureRandom.hex(32)
    end
  end
end
