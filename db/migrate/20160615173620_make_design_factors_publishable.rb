class MakeDesignFactorsPublishable < ActiveRecord::Migration
  def up
    add_column :design_factors, :published, :boolean, null: false, default: true, index: true
    add_column :design_factors, :published_on, :datetime, null: true
    execute "UPDATE design_factors SET published_on = updated_at"
    execute "ALTER TABLE design_factors ADD CONSTRAINT design_factors_pub_chk CHECK (published = FALSE OR published_on IS NOT NULL)"
    add_index :design_factors, :published

    add_reference :design_factors, :user, index: true
    add_foreign_key :design_factors, :users, on_update: :cascade, on_delete: :nullify
  end

  def down
    execute "ALTER TABLE design_factors DROP CONSTRAINT IF EXISTS design_factors_pub_chk"
    remove_column :design_factors, :published_on
    remove_column :design_factors, :published

    remove_reference :design_factors, :user
  end
end
