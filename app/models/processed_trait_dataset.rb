class ProcessedTraitDataset < ActiveRecord::Base

  belongs_to :plant_trial
  belongs_to :trait_descriptor
  belongs_to :plant_population

  has_many :qtls

end
