class TraitGrade < ActiveRecord::Base

  belongs_to :trait_descriptor

  include Annotable
end
