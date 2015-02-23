class TaxonomyTerm < ActiveRecord::Base
  belongs_to :parent,
             class_name: 'TaxonomyTerm',
             foreign_key: 'taxonomy_term_id'

  scope :children_of, ->(parent_id) { where(taxonomy_term_id: parent_id) }
end
