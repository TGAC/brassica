class Trait < ActiveRecord::Base
  has_many :trait_descriptors

  validates :name, presence: true, uniqueness: true
  validates :label, presence: true

  include Filterable

  def self.names
    order(:name).pluck(:name)
  end

  def self.permitted_params
    [
      search: [
        'name'
      ],
      query: [
        'id'
      ]
    ]
  end
end
