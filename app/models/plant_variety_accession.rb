# Read-only model based on a database view joining plant_accessions and plant_lines.
class PlantVarietyAccession < ActiveRecord::Base
  include PublishableQueries

  belongs_to :user
  belongs_to :plant_variety
  belongs_to :plant_line

  def self.read_only?
    true
  end

  def read_only?
    true
  end
end
