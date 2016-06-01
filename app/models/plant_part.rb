class PlantPart < ActiveRecord::Base
  has_many :trait_descriptors

  validates :plant_part,
            presence: true,
            uniqueness: true

  include Filterable

  def self.permitted_params
    [
      search: [
        'plant_part'
      ]
    ]
  end

  include Annotable
end
