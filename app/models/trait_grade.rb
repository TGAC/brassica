class TraitGrade < ActiveRecord::Base

  belongs_to :trait_descriptor

  include Annotable

  validates :trait_grade,
            presence: true
end
