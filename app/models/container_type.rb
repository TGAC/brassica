class ContainerType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
