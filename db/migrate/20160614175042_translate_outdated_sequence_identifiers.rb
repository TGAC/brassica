class TranslateOutdatedSequenceIdentifiers < ActiveRecord::Migration
  def up
    File.foreach('db/data/probe_accessions.csv') do |line|
      sequence_id, accession = line.strip.split(',')
      execute("UPDATE probes SET sequence_id ='#{accession}' WHERE sequence_id = '#{sequence_id}';")
    end

    File.foreach('db/data/bac_accessions.csv') do |line|
      sequence_id, accession = line.strip.split(',')
      execute("UPDATE map_locus_hits SET bac_hit_seq_id ='#{accession}' WHERE bac_hit_seq_id = '#{sequence_id}';")
    end
  end

  def down
    File.foreach('db/data/probe_accessions.csv') do |line|
      sequence_id, accession = line.strip.split(',')
      execute("UPDATE probes SET sequence_id ='#{sequence_id}' WHERE sequence_id = '#{accession}';")
    end

    File.foreach('db/data/bac_accessions.csv') do |line|
      sequence_id, accession = line.strip.split(',')
      execute("UPDATE map_locus_hits SET bac_hit_seq_id ='#{sequence_id}' WHERE bac_hit_seq_id = '#{accession}';")
    end
  end
end
