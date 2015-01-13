class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login, null: false
      t.string :email
      t.string :full_name

      t.timestamps null: false
    end

    add_index :users, :login, unique: true
  end
end
