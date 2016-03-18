class GenotypeMatrix < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :linkage_map

  validates :matrix_compiled_by,
            presence: true

  validates :original_file_name,
            presence: true

  validates :number_markers_in_matrix,
            presence: true

  validates :number_lines_in_matrix,
            presence: true

  validates :matrix,
            presence: true

  validates_with PublicationValidator

  include Annotable
end
