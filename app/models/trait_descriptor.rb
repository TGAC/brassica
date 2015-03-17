class TraitDescriptor < ActiveRecord::Base

  has_many :trait_grades
  has_many :trait_scores
  has_many :processed_trait_datasets

end
