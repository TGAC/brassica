class CreateMeasurementUnits < ActiveRecord::Migration
  def change
    create_table :measurement_units do |t|
      t.integer :parent_ids, array: true
      t.string :name, null: false
      t.string :term
      t.string :description, null: false
      t.boolean :canonical, null: false, default: true

      t.timestamps null: false
    end

    add_index :measurement_units, [:name, :term], unique: true
    add_index :measurement_units, :term, unique: true
  end
end
