class PurgeOldDefaults < ActiveRecord::Migration
  def up
    tables = [
        :countries,
        :design_factors,
        :linkage_groups,
        :linkage_maps,
        :map_linkage_group_lists,
        :map_locus_hits,
        :map_positions,
        :marker_assays,
        :marker_sequence_assignments,
        :plant_accessions,
        :plant_lines,
        :plant_parts,
        :plant_populations,
        :plant_population_lists,
        :plant_scoring_units,
        :plant_trials,
        :plant_varieties,
        :population_loci,
        :pop_type_lookup,
        :primers,
        :probes,
        :processed_trait_datasets,
        :qtl,
        :qtl_jobs,
        :restriction_enzymes,
        :submissions,
        :trait_descriptors,
        :trait_grades,
        :trait_scores
    ]
    columns = [
        :comments,
        :entered_by_whom,
        :data_provenance,
        :data_owned_by
    ]
    purgable_values = [
        'no comment',
        'No comment'
    ]

    tables.each do |table|
      columns.each do |column|
        if column_exists?(table, column)
          purgable_values.each do |value|
            execute ("UPDATE #{table.to_s} SET #{column.to_s} = NULL WHERE #{column.to_s} = '#{value}'")
          end
        end
      end
    end
  end

  def down
  end
end
