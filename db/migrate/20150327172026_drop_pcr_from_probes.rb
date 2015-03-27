class DropPcrFromProbes < ActiveRecord::Migration
  def up
    remove_column :probes, :pcr_yes_or_no
  end

  def down
    add_column :probes, :pcr_yes_or_no, :string, default: 'N'
  end
end