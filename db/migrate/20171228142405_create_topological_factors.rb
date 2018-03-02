class CreateTopologicalFactors < ActiveRecord::Migration
  def change
    create_table :topological_factors do |t|
      t.integer :parent_ids, array: true
      t.string :name, null: false
      t.string :term
      t.boolean :canonical, null: false, default: true

      t.timestamps null: false
    end

    add_index :topological_factors, :name, unique: true
    add_index :topological_factors, :term, unique: true
  end
end
