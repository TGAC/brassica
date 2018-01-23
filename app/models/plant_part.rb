class PlantPart < ApplicationRecord
  has_many :trait_descriptors

  validates :plant_part,
            presence: true,
            uniqueness: true

  include Filterable

  def self.permitted_params
    [
      search: [
        'plant_part'
      ],
      query: [
        'id'
      ]
    ]
  end

  include Annotable
end
