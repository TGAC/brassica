class ProcessedTraitDataset < ApplicationRecord
  belongs_to :plant_trial
  belongs_to :trait_descriptor

  after_touch { qtls.each(&:touch) }
  before_destroy { qtls.each(&:touch) }

  has_many :qtls

  validates :processed_trait_dataset_name,
            presence: true,
            uniqueness: true

  include Annotable
end
