class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.timestamps
      t.string :token, null: false, index: :unique
      t.references :user, null: false
    end

    add_foreign_key :api_keys, :users, on_delete: :cascade, on_update: :cascade
  end
end
