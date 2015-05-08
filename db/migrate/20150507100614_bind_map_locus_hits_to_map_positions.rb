class BindMapLocusHitsToMapPositions < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up
    unless column_exists?(:map_locus_hits, :map_position_id)
      add_column :map_locus_hits, :map_position_id, :int
      upsert_index(:map_locus_hits, :map_position_id)
    end

    mlhs = execute("SELECT * FROM map_locus_hits")
    count_0 = 0
    count_1 = 0
    count_n = 0
    mlhs.each do |mlh|
      mps = execute("SELECT * FROM map_positions WHERE population_locus_id = #{mlh['population_locus_id']} \
        AND linkage_group_id = #{mlh['linkage_group_id']} AND map_position = '#{mlh['map_position']}'")
      if mps.ntuples == 0
        count_0 += 1
      elsif mps.ntuples == 1
        count_1 += 1
        execute("UPDATE map_locus_hits SET map_position_id = #{mps.first['id']} WHERE id = #{mlh['id']}")
      else
        puts "Found #{mps.length} MPs for the following combination of keys: #{mlh['population_locus_id']}, #{mlh['linkage_group_id']}, #{mlh['map_position']}"
        count_n += 1
      end
    end
    puts "Processing complete. Found #{count_0} MLHs linking to 0 MPs; #{count_1} MLHs linking to 1 MP and #{count_n} MLHs linking to more than 1 MP."
  end

  def down
    if column_exists?(:map_locus_hits, :map_position_id)
      remove_column :map_locus_hits, :map_position_id
    end
  end
end