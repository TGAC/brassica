class AddSequenceIdentifierToPlantLines < ActiveRecord::Migration
  def change
    add_column :plant_lines, :sequence_identifier, :string
  end
end
