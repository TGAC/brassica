namespace :curate do
  desc 'Performs curation of CropStoreDB data'
  task plant_taxonomy: :environment do
    # Now comes the hard part: we need to heuristically link existing PL records
    # to TTs based on the content of their species, genus and subtaxa fields
    cntr = 0
    success_cntr = 0

    failures = []

    PlantLine.all.each do |pl|
      tgt_subtaxa = pl.subtaxa ? pl.subtaxa.strip.gsub('  ', ' ').gsub(' ?', '?') : ''
      tgt_species = pl.species ? pl.species.strip : ''
      tgt_genus = pl.genus ? pl.genus.strip : ''
      pl_full_name = "#{tgt_genus} #{tgt_species} #{tgt_subtaxa}"
      name_to_find = if !meaningful(tgt_species)
                       "#{tgt_genus}"
                     elsif !meaningful(tgt_subtaxa)
                       "#{tgt_genus} #{tgt_species}"
                     else
                       ["#{tgt_genus} #{tgt_species} #{tgt_subtaxa}",
                        "#{tgt_genus} #{tgt_species} var. #{tgt_subtaxa}",
                        "#{tgt_genus} #{tgt_species} subsp. #{tgt_subtaxa}"]
                     end

      cntr += 1
      tt = TaxonomyTerm.find_by(name: name_to_find)
      if tt
        pl.taxonomy_term = tt
        pl.save
        success_cntr += 1
      else
        failures << pl_full_name
      end
      puts "...processed #{cntr} records..." if cntr % 1000 == 0
    end
    puts "---------------------------"
    puts "Run complete: #{cntr} records processed; #{success_cntr} successes and #{failures.size} failures."
    puts "Failures:"
    puts failures.uniq.join("\n")
  end

  def meaningful(term)
    blank_records = ['unspecified', '', 'not applicable', 'none']
    term && !(blank_records.include? term)
  end
end
