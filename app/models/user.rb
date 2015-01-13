class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :trackable, :timeoutable

  include Nondestroyable

  validates :login, presence: true, uniqueness: { case_sensitive: false }
end
