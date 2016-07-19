namespace :curate do
  # This curation task is there only to build proper mapping files. Once these files are
  # inside the repository, there is not need to run this task again. However, this code
  # should stay here for two purposes:
  # - provenance (i.e. checking what was wrong if problematic mapping is detected)
  # - future reference (in case we need something similar in the future).
  #
  # It partially addresses issue #541 of translating outdated GI identifiers from NCBI
  # to new Accession identifiers. Old identifiers will be removed from NCBI soon.
  # The reason why this is separate is that mass file retrieval, from an external API, might
  # be erratic, so in order to keep the data migration safe and smooth, I decided
  # to use local files as an intermediate step.
  #
  # Related migration: 20160614175042_translate_outdated_sequence_identifiers.rb
  task get_new_sequence_accessions: :environment do
    puts "Building mapping for Probe sequences"
    probes = Probe.where.not(sequence_id: nil).pluck(:id, :sequence_id)
    probe_accessions = ''
    probes.each do |id, sequence_id|
      accession = `curl -s "http://www.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucest&rettype=acc&retmode=text&id=#{sequence_id}"`
      probe_accessions += "#{sequence_id},#{accession}"
      puts "#{sequence_id},#{accession}"
    end
    File.write('db/data/probe_accessions.csv', probe_accessions)

    puts "Building mapping for MLH bac sequences"
    sequence_ids = MapLocusHit.pluck(:bac_hit_seq_id).uniq.compact
    bac_accessions = {}
    sequence_ids.each_with_index do |sequence_id, i|
      accession = `curl -s "http://www.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&rettype=acc&retmode=text&id=#{sequence_id}"`
      bac_accessions[sequence_id] = accession
      puts "#{i+1}: #{sequence_id},#{accession}"
    end
    File.write('db/data/bac_accessions.csv', bac_accessions.map{ |seq,acc| "#{seq},#{acc}" }.join)

    puts "Building mapping for MLH associated sequences"
    sequence_ids = MapLocusHit.pluck(:associated_sequence_id).uniq.compact
    seq_accessions = {}
    sequence_ids.each_with_index do |sequence_id, i|
      next unless sequence_id.length >= 8
      accession = `curl -s "http://www.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&rettype=acc&retmode=text&id=#{sequence_id}"`
      seq_accessions[sequence_id] = accession
      puts "#{i+1}: #{sequence_id},#{accession}"
    end
    File.write('db/data/mlh_accessions.csv', seq_accessions.map{ |seq,acc| "#{seq},#{acc}" }.join)
  end
end
