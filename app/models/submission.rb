class Submission < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :step, presence: true

end
