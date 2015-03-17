class ProcessedTraitDataset < ActiveRecord::Base

  belongs_to :plant_trial, foreign_key: 'trial_id'
  belongs_to :trait_descriptor
  belongs_to :plant_population, foreign_key: 'population_id'

  has_many :qtls

end
