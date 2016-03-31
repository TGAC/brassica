class ProcessedTraitDataset < ActiveRecord::Base
  belongs_to :plant_trial
  belongs_to :trait_descriptor

  has_many :qtls

  validates :processed_trait_dataset_name,
            presence: true,
            uniqueness: true

  after_touch { qtls.each(&:touch) }

  include Annotable
end
