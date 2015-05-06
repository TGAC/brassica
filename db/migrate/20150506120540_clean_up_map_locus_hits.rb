class CleanUpMapLocusHits < ActiveRecord::Migration
  def up
    if column_exists?(:map_locus_hits, :cs_sequence_data_status)
      remove_column :map_locus_hits, :cs_sequence_data_status
    end

    if column_exists?(:map_locus_hits, :sqs_sequence_data_status)
      remove_column :map_locus_hits, :sqs_sequence_data_status
    end

    if column_exists?(:map_locus_hits, :map_data_status)
      remove_column :map_locus_hits, :map_data_status
    end
  end

  def down
  end
end
