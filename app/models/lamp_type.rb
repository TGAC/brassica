class LampType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
