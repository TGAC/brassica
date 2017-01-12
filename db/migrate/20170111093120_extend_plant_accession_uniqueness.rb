class ExtendPlantAccessionUniqueness < ActiveRecord::Migration
  def up
    execute("DROP INDEX IF EXISTS plant_accessions_plant_accession_originating_organisation_idx")
    execute("CREATE UNIQUE INDEX plant_accessions_pa_oo_yp_idx ON plant_accessions(plant_accession, originating_organisation, year_produced)")
  end

  def down
    execute("DROP INDEX IF EXISTS plant_accessions_pa_oo_yp_idx")
    execute("CREATE UNIQUE INDEX plant_accessions_plant_accession_originating_organisation_idx ON plant_accessions (plant_accession, originating_organisation)")
  end
end
