class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.timestamps null: false
      t.string :name, null: false
      t.json :args, null: false, default: {}
      t.integer :analysis_type, null: false, default: 0, length: 2
      t.integer :status, null: false, default: 0, length: 2
      t.integer :owner_id, null: false
      t.integer :associated_pid
    end

    add_foreign_key :analyses, :users, column: :owner_id, on_delete: :cascade
    add_index :analyses, [:owner_id, :analysis_type]
  end
end
