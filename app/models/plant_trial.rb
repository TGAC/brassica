class PlantTrial < ActiveRecord::Base

  has_many :plant_scoring_units
  has_many :processed_trait_datasets, foreign_key: 'trial_id'
  belongs_to :plant_population
  belongs_to :country

end
