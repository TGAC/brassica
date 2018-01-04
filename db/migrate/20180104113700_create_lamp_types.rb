class CreateLampTypes < ActiveRecord::Migration
  def change
    create_table :lamp_types do |t|
      t.string :name, null: false, index: true
      t.boolean :canonical, null: false, default: true
      t.timestamps null: false
    end
  end
end
