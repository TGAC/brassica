class ApiKey < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :assign_token, on: :create

  private

  def assign_token
    while token.blank? || self.class.exists?(token: token)
      self.token = SecureRandom.hex.to_s
    end
  end
end
