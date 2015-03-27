class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.references :user, null: false
      t.string :step, null: false
      t.json :content, null: false, default: {}
      t.boolean :finalized, null: false, default: false, index: true
      t.integer :submission_type, null: false, index: true

      t.timestamps null: false
    end

    add_index :submissions, :user_id
  end
end
