class FixDataProvenanceInRestrictionEnzymes < ActiveRecord::Migration
  def up
    execute "ALTER TABLE restriction_enzymes ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE restriction_enzymes ALTER COLUMN data_provenance DROP DEFAULT"
  end

  def down
  end
end
