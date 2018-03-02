class CreatePlantTreatmentTypes < ActiveRecord::Migration
  def change
    create_table :plant_treatment_types do |t|
      t.integer :parent_ids, array: true
      t.string :name, null: false
      t.string :term, null: false

      t.timestamps null: false
    end

    add_index :plant_treatment_types, :name, unique: true
    add_index :plant_treatment_types, :term, unique: true
  end
end
