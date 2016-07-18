class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :trackable, :timeoutable,
         omniauth_providers: [:orcid]

  include Nondestroyable

  has_many :submissions
  has_one :api_key

  validates :login, presence: true, uniqueness: { case_sensitive: false }

  after_create :create_api_key!

  def self.find_or_create_from_auth_hash(auth_hash)
    user = self.find_or_initialize_by(login: auth_hash['uid'])
    user.full_name = auth_hash['full_name'] if auth_hash['full_name']
    user.save
    user
  end

end
