namespace :curate do
  desc 'Performs curation of CropStoreDB data'
  task plant_taxonomy: :environment do
    # Now comes the hard part: we need to heuristically link existing PL records
    # to TTs based on the content of their species, genus and subtaxa fields
    pls = PlantLine.all;
    @cntr = 0
    @success_cntr = 0
    @blank_records = ['unspecified', 'not applicable', 'none']
    all_genera = pls.collect{|pl| pl.genus}.uniq
    all_species = pls.collect{|pl| pl.species}.uniq
    all_subtaxa = pls.collect{|pl| pl.subtaxa}.uniq

    puts "Found #{all_genera.length} genera, #{all_species.length} species
      and #{all_subtaxa.length} subtaxa."

    pls.each do |pl|
      # Start in reverse order - look for subtaxa in TT
      tgt_subtaxa = pl.subtaxa.lstrip.rstrip
      tgt_species = pl.species.lstrip.rstrip
      tgt_genus = pl.genus.lstrip.rstrip
      pl_full_name = "#{tgt_genus} #{tgt_species} #{tgt_subtaxa}"

      # Attempt to match by subtaxa
      if meaningful(tgt_subtaxa) and all_genera.include? tgt_subtaxa
        fail("FAIL #{@cntr.to_s}: Ambiguous record: #{pl_full_name}. Subtaxa #{tgt_subtaxa} duplicates existing genus name. Giving up.")
        next pl
      end
      if meaningful(tgt_subtaxa) and all_species.include? tgt_subtaxa
        # Careful here - subtaxa name replicates species name.
        # Try to match by combination of species and genus name
        candidate_tts = TaxonomyTerm.all.select { |tt|
          (tt.name.include? "#{tgt_species} #{tgt_subtaxa}") ||
          (tt.name.include? "#{tgt_species} var. #{tgt_subtaxa}") ||
          (tt.name.include? "#{tgt_species} subsp. #{tgt_subtaxa}")
        }
        if candidate_tts.length == 1
          pl.taxonomy_term = candidate_tts.first
          pl.save
          @success_cntr += 1
          @cntr += 1
          next pl
        else
          fail("FAIL #{@cntr.to_s}: Ambiguous record: #{pl_full_name}. Subtaxa #{tgt_subtaxa} duplicates existing species name. Giving up.")
          next pl
        end
      end
      if meaningful(tgt_subtaxa)
        # Look for subtaxa in TT
        candidate_tts = TaxonomyTerm.all.select{|tt| tt.name.include? tgt_subtaxa}
        if candidate_tts.length == 1
          pl.taxonomy_term = candidate_tts.first
          pl.save
          @success_cntr += 1
          @cntr += 1
          next pl
        elsif candidate_tts.length == 0
          fail("FAIL #{@cntr.to_s}: No candidate TT found for #{pl_full_name}.")
          next pl
        else
          fail("FAIL #{@cntr.to_s}: More than one candidate TT found for for #{pl_full_name}.")
          next pl
        end
      end

      # tgt_subtaxa not meaningful or absent - try to assign TT by species
      if meaningful(tgt_species) and all_genera.include? tgt_species
        fail("FAIL #{@cntr.to_s}: Ambiguous record: #{pl_full_name}. Species #{tgt_species} duplicates existing genus name. Giving up.")
        next pl
      end
      if meaningful(tgt_species)
      # Try to find a corresponding record in TTs. Assume genus is always Brassica.
        candidate_tts = TaxonomyTerm.where("name = 'Brassica #{tgt_species}'").all
        if candidate_tts.length == 1
          pl.taxonomy_term = candidate_tts.first
          pl.save
          @success_cntr += 1
          @cntr += 1
          next pl
        elsif candidate_tts.length == 0
          fail("FAIL #{@cntr.to_s}: No candidate TT found for #{pl_full_name}.")
          next pl
        else
          fail("FAIL #{@cntr.to_s}: More than one candidate TT found for #{pl_full_name}.")
          next pl
        end
      end

      # tgt_species also not meaningful or absent - try to assign to Brassica sp.
      if meaningful(tgt_genus)
        pl.taxonomy_term = TaxonomyTerm.find_by(name: 'Brassica sp.')
        pl.save
        @success_cntr += 1
        @cntr += 1
        next pl
      end

      # Catch-all failure
      fail("FAIL #{@contr.to_s} Unknown PL entity: #{pl_full_name}. Giving up.")
    end
    puts "---------------------------"
    puts "Run complete: #{@cntr.to_s} records processed; #{@success_cntr.to_s} successes and #{(@cntr - @success_cntr).to_s} failures."
  end

  # Adds a non-canonical taxonomy term
  def add_taxonomy_term (name)
    TaxonomyTerm.new(label: 'CROPSTORE', name: name, canonical: false)
  end

  def meaningful(term)
    term && !(@blank_records.include? term)
  end

  def fail(message)
    puts message
    @cntr+=1
  end

end
