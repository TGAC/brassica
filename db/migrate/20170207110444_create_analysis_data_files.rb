class CreateAnalysisDataFiles < ActiveRecord::Migration
  def change
    create_table :analysis_data_files do |t|
      t.timestamps null: false
      t.references :analysis, foreign_key: true
      t.attachment :file
      t.integer :role, null: false, default: 0
      t.integer :data_type, null: false, default: 0
      t.integer :owner_id, null: false
    end

    add_foreign_key :analysis_data_files, :users, column: :owner_id, on_delete: :cascade
    add_index :analysis_data_files, [:analysis_id, :role, :data_type]
    add_index :analysis_data_files, :owner_id
  end
end
