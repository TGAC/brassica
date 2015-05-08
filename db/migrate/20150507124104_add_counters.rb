class AddCounters < ActiveRecord::Migration
  def up
    table_counters.each do |table, counters|
      counters.each do |counter|
        unless column_exists?(table, counter)
          add_column table, counter, :integer, null: false, default: 0
          klass = table.to_s.classify.constantize
          klass.reset_column_information
          klass.pluck(:id).each do |object_id|
            klass.reset_counters object_id, counter[0..-7]
          end
        end
      end
    end
  end

  def down
    table_counters.each do |table, counters|
      counters.each do |counter|
        if column_exists?(table, counter)
          remove_column table, counter
        end
      end
    end
  end

  def table_counters
    {
      linkage_maps: [
        :map_linkage_group_lists_count,
        :map_locus_hits_count
      ],
      linkage_groups: [
        :map_linkage_group_lists_count,
        :map_positions_count,
        :map_locus_hits_count
      ],
      map_positions: [
        :map_locus_hits_count
      ],
      marker_assays: [
        :population_loci_count
      ],
      plant_populations: [
        :plant_population_lists_count,
        :linkage_maps_count,
        :plant_trials_count,
        :population_loci_count
      ],
      plant_trials: [
        :plant_scoring_units_count
      ],
      plant_scoring_units: [
        :trait_scores_count
      ],
      plant_accessions: [
        :plant_scoring_units_count
      ],
      population_loci: [
        :map_locus_hits_count,
        :map_positions_count
      ],
      primers: [
        :marker_assays_a_count,
        :marker_assays_b_count
      ],
      probes: [
        :marker_assays_count
      ],
      qtl_jobs: [
        :qtls_count
      ]
    }
  end
end
