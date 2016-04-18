class DropDuplicateIndices < ActiveRecord::Migration
  def up
    if index_exists?(:countries, :country_code, name: 'idx_ccs_country_code')
      remove_index(:countries, name: 'idx_ccs_country_code')
    end
    if index_exists?(:map_positions, :mapping_locus, name: 'idx_143597_mapping_locus')
      remove_index(:map_positions, name: 'idx_143597_mapping_locus')
    end
    if index_exists?(:marker_sequence_assignments, :canonical_marker_name, name: 'idx_143632_canonical_marker_name')
      remove_index(:marker_sequence_assignments, name: 'idx_143632_canonical_marker_name')
    end
    if index_exists?(:population_loci, :mapping_locus, name: 'idx_143961_mapping_locus')
      remove_index(:population_loci, name: 'idx_143961_mapping_locus')
    end
    if index_exists?(:qtl_jobs, :linkage_map_label, name: 'idx_144140_linkage_map_id')
      remove_index(:qtl_jobs, name: 'idx_144140_linkage_map_id')
    end
    if index_exists?(:trait_descriptors, :descriptor_label, name: 'idx_144197_trait_descriptor_id')
      remove_index(:trait_descriptors, name: 'idx_144197_trait_descriptor_id')
    end
  end

  def down
    # Nothing to be done.
  end
end
