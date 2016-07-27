class AdjustIndicesForPlantAccessions < ActiveRecord::Migration
  def change
    remove_index :plant_accessions, column: :plant_accession, name: 'plant_accessions_plant_accession_idx'
    add_index :plant_accessions, [:plant_accession, :originating_organisation], name: 'plant_accessions_pa_oo_idx'
  end
end
