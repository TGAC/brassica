class AddLabelToPlantParts < ActiveRecord::Migration
  def up
    add_column :plant_parts, :label, :string, index: true, default: 'CROPSTORE', null: false
    add_column :plant_parts, :canonical, :boolean, default: false, null: false
    execute "UPDATE plant_parts SET label = 'PO:0000003' WHERE plant_part = 'whole plant'"

    PlantPart.reset_column_information
    Rake::Task['obo:plant_parts'].invoke
  end

  def down
    remove_column :plant_parts, :label
    remove_column :plant_parts, :canonical

    PlantPart.all.each do |pp|
      psu_count = PlantScoringUnit.where(plant_part_id: pp.id).count
      pp.destroy if psu_count.to_i == 0
    end
  end
end
