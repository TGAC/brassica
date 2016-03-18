class ProcessedTraitDataset < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :plant_trial
  belongs_to :trait_descriptor

  has_many :qtls

  validates :processed_trait_dataset_name,
            presence: true,
            uniqueness: true

  validates_with PublicationValidator

  after_touch { qtls.each(&:touch) }

  include Annotable
end
