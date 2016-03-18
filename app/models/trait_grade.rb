class TraitGrade < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :trait_descriptor

  validates :trait_grade,
            presence: true

  validates_with PublicationValidator

  include Annotable
end
