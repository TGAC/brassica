class AddCanonicalToPlantTreatmentTypes < ActiveRecord::Migration
  def change
    add_column :plant_treatment_types, :canonical, :boolean, null: false, default: true
    change_column_null :plant_treatment_types, :term, true
  end
end
