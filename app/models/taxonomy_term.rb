class TaxonomyTerm < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :parent,
             class_name: 'TaxonomyTerm',
             foreign_key: 'taxonomy_term_id'

  has_many :plant_lines

  has_many :plant_populations

  has_many :probes

  validates :name, uniqueness: true
  validates :label, presence: true

  validates_with PublicationValidator

  scope :children_of, ->(parent_id) { where(taxonomy_term_id: parent_id) }

  after_update { plant_lines.each(&:touch) }
  after_update { plant_populations.each(&:touch) }
  after_update { probes.each(&:touch) }

  def self.names
    order(:name).pluck(:name)
  end
end
