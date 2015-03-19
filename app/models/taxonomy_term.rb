class TaxonomyTerm < ActiveRecord::Base
  belongs_to :parent,
             class_name: 'TaxonomyTerm',
             foreign_key: 'taxonomy_term_id'

  has_many :plant_lines

  validates :name, uniqueness: true

  scope :children_of, ->(parent_id) { where(taxonomy_term_id: parent_id) }

  def self.names
    order(:name).pluck(:name)
  end
end
