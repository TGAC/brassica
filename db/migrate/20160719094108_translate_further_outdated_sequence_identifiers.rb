class TranslateFurtherOutdatedSequenceIdentifiers < ActiveRecord::Migration
  def up
    File.foreach('db/data/mlh_accessions.csv') do |line|
      sequence_id, accession = line.strip.split(',')
      execute("UPDATE map_locus_hits SET associated_sequence_id ='#{accession}' WHERE associated_sequence_id = '#{sequence_id}';")
    end
  end

  def down
    File.foreach('db/data/mlh_accessions.csv') do |line|
      sequence_id, accession = line.strip.split(',')
      execute("UPDATE map_locus_hits SET associated_sequence_id ='#{sequence_id}' WHERE associated_sequence_id = '#{accession}';")
    end
  end
end
