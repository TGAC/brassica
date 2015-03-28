namespace :curate do
  desc 'Performs curation of CropStoreDB data'
  task plant_taxonomy: :environment do
    # Now comes the hard part: we need to heuristically link existing PL records
    # to TTs based on the content of their species, genus and subtaxa fields
    cntr = 0
    success_cntr = 0

    failures = []

    puts "Processing PlantLine objects..."

    triples = PlantLine.pluck(:genus, :species, :subtaxa).uniq
    triples.each do |triple|
      tgt_subtaxa = triple[2] ? triple[2].strip.gsub('  ', ' ').gsub(' ?', '?') : ''
      tgt_species = triple[1] ? triple[1].strip : ''
      tgt_genus = triple[0] ? triple[0].strip : ''

      pl_full_name = "#{tgt_genus} #{tgt_species} #{tgt_subtaxa}"
      name_to_find = if !meaningful?(tgt_species)
                       "#{tgt_genus}"
                     elsif !meaningful?(tgt_subtaxa)
                       "#{tgt_genus} #{tgt_species}"
                     else
                       ["#{tgt_genus} #{tgt_species} #{tgt_subtaxa}",
                        "#{tgt_genus} #{tgt_species} var. #{tgt_subtaxa}",
                        "#{tgt_genus} #{tgt_species} subsp. #{tgt_subtaxa}"]
                     end

      tt = TaxonomyTerm.find_by(name: name_to_find)
      unless tt
        # Second try after typo fixes
        fixed_name = [name_to_find].flatten.map{ |n| data_fixes(n) }
        tt = TaxonomyTerm.find_by(name: fixed_name)
      end
      pls = PlantLine.where(genus: triple[0], species: triple[1], subtaxa: triple[2])
      cntr += pls.count
      if tt
        pls.update_all(taxonomy_term_id: tt.id)
        success_cntr += pls.count
      else
        failures << pl_full_name
      end
      puts "...processed #{cntr} records..." if cntr % 1000 == 0
    end
    puts "---------------------------"
    puts "Run complete: #{cntr} PL records processed; #{success_cntr} successes and #{failures.size} failures."
    puts "Failures:"
    puts failures.uniq.join("\n")

    if failures.empty?
      puts 'No failures - performing database cleanup'
      puts '1. Removing trash PL records'
      begin
        PlantLine.where(genus: blank_records).destroy_all
      rescue ActiveRecord::StatementInvalid
        puts '  Relevant columns already removed.'
      end
      puts '2. Removing genus/species/subtaxa columns'
      PlantLine.connection.execute('ALTER TABLE plant_lines DROP COLUMN IF EXISTS genus')
      PlantLine.connection.execute('ALTER TABLE plant_lines DROP COLUMN IF EXISTS species')
      PlantLine.connection.execute('ALTER TABLE plant_lines DROP COLUMN IF EXISTS subtaxa')
      puts 'Finished'
    end

    # Now do the same for plant_populations
    cntr = 0
    success_cntr = 0

    failures = []

    puts "Processing PP objects..."

    PlantPopulation.all.each do |pp|
      tgt_species = pp.species ? pp.species.strip : ''
      tgt_genus = pp.genus ? pp.genus.strip : ''
      pp_full_name = "#{tgt_genus} #{tgt_species}"
      name_to_find = if !meaningful?(tgt_species)
                       "#{tgt_genus}"
                     else
                       "#{tgt_genus} #{tgt_species}"
                     end
      cntr += 1
      tt = TaxonomyTerm.find_by(name: name_to_find)
      unless tt
        # Second try after typo fixes
        fixed_name = [name_to_find].flatten.map{ |n| data_fixes(n) }
        tt = TaxonomyTerm.find_by(name: fixed_name)
      end
      if tt
        pp.taxonomy_term = tt
        pp.save
        success_cntr += 1
      else
        failures << pp_full_name
      end
      puts "...processed #{cntr} records..." if cntr % 1000 == 0
    end

    puts "---------------------------"
    puts "Run complete: #{cntr} PP records processed; #{success_cntr} successes and #{failures.size} failures."
    puts "Failures:"
    puts failures.uniq.join("\n")

    if failures.empty?
      puts 'No failures - performing database cleanup'
      puts '1. Removing trash PP records'
      begin
        PlantPopulation.where(genus: blank_records).destroy_all
      rescue ActiveRecord::StatementInvalid
        puts '  Relevant columns already removed.'
      end
      puts '2. Removing genus/species columns'
      PlantLine.connection.execute('ALTER TABLE plant_populations DROP COLUMN IF EXISTS genus')
      PlantLine.connection.execute('ALTER TABLE plant_populations DROP COLUMN IF EXISTS species')
      puts 'Finished'
    end

  end

  def blank_records
    ['unspecified', '', 'not applicable', 'none']
  end

  def meaningful?(term)
    term && !(blank_records.include? term)
  end

  def data_fixes(name)
    {
      'captitata' => 'capitata',
      'oleracia' => 'oleracea',
      'olifeira' => 'oleifera',
      'bourgaei' => 'bourgeaui',
      'napiformes' => 'napiformis',
      ' conica' => '',
      'hybrid' => 'sp.',
      'MIXED' => 'sp.',
      'spp' => 'sp.'
    }.each do |from,to|
      name = name.gsub(from, to)
    end
    name
  end
end
