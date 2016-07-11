class AssignMissingOriginatingOrganisation < ActiveRecord::Migration
  def up
    execute "UPDATE plant_accessions SET originating_organisation = 'RRES' WHERE originating_organisation IS NULL"
  end

  def down
    execute "UPDATE plant_accessions SET originating_organisation = NULL WHERE originating_organisation = 'RRES'"
  end
end
