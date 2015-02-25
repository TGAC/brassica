class LinkPlantLinesToTaxonomyTerms < ActiveRecord::Migration
  def up
    add_reference :plant_lines, :taxonomy_term, index: true

    # Now comes the hard part: we need to heuristically link existing PL records
    # to TTs based on the content of their species, genus and subtaxa fields
    pls = PlantLine.all;
    cntr = 0
    success_cntr = 0
    all_genera = pls.collect{|pl| pl.genus}.uniq
    all_species = pls.collect{|pl| pl.species}.uniq
    all_subtaxa = pls.collect{|pl| pl.subtaxa}.uniq
    blank_records = ['unspecified', 'not applicable', 'none']

    puts "Found #{all_genera.length} genera, #{all_species.length} species
      and #{all_subtaxa.length} subtaxa."

    pls.each do |pl|
      print "PL: #{pl.genus} #{pl.species} #{pl.subtaxa}"
      # Start in reverse order - look for subtaxa in TT
      tgt_subtaxa = pl.subtaxa
      # Purge leading and trailing whitespace
      tgt_subtaxa = tgt_subtaxa.lstrip.rstrip
      if tgt_subtaxa.present? and !(all_genera.include? tgt_subtaxa) and !(all_species.include? tgt_subtaxa)
        # Look for subtaxa in TT
        candidate_tts = TaxonomyTerm.all.select{|tt| tt.name.include? tgt_subtaxa}
        if candidate_tts.length == 1
          puts "...found TT: #{candidate_tts.first.name}; assigning to PL."
          pl.taxonomy_term == candidate_tts.first
          pl.save
          success_cntr += 1
          cntr += 1
          next pl
        elsif candidate_tts.length == 0
          puts "...No candidate TT found for subtaxa #{tgt_subtaxa}. Unable to assign TT."
          cntr +=1
          next pl
        else
          puts "...Found more than one candidate TT for subtaxa #{tgt_subtaxa}. PL record is ambiguous - unable to assign TT."
          cntr += 1
          next pl
        end
      else
        # Special case: if target subtaxa is 'unspecified', 'not applicable' or 'none'
        # then try to assign PL to a species-wide TT record instead
        if blank_records.include? tgt_subtaxa
          tgt_species = pl.species.lstrip.rstrip
          if tgt_species.present? and !(all_genera.include? tgt_species)
            # Try to find a corresponding record in TTs. Assume genus is always Brassica.
            candidate_tts = TaxonomyTerm.where("name = 'Brassica #{tgt_species}'").all
            if candidate_tts.length == 1
              puts "... found TT: #{candidate_tts.first.name}; assigning to PL."
              pl.taxonomy_term == candidate_tts.first
              pl.save
              success_cntr += 1
              cntr += 1
              next pl
            elsif candidate_tts.length == 0
              puts "...No candidate TT found for species #{tgt_species}. Unable to assign TT."
              cntr +=1
              next pl
            else
              puts "...Found more than one candidate TT for species #{tgt_species}. PL record is ambiguous - unable to assign TT."
              cntr += 1
              next pl
            end
          elsif blank_records.include? tgt_species
            # Assign to Brassica sp.
            pl.taxonomy_term = TaxonomyTerm.find_by(name: 'Brassica sp.')
            pl.save
            puts "...blank species name detected; assigning generic TT: Brassica sp."
            success_cntr += 1
            cntr += 1
            next pl
          else
            puts "...blank or unknown species name: #{tgt_species}. Unable to assign TT."
            cntr += 1
            next pl
          end
        end
        if tgt_subtaxa.blank?
          puts "...PL subtaxa not defined. Unable to assign TT."
          cntr += 1
          next pl
        elsif all_genera.include? tgt_subtaxa
          puts "...Ambiguous subtaxa name: #{tgt_subtaxa} duplicates existing genus name. Unable to assign TT."
          cntr += 1
          next pl
        elsif all_species.include? tgt_subtaxa
          puts "...Ambiguous subtaxa name: #{tgt_subtaxa} duplicates existing species name. Unable to assign TT."
          cntr += 1
          next pl
        end
      end
    end  #End subtaxa loop
    puts "---------------------------"
    puts "Run complete: #{cntr.to_s} records processed; #{success_cntr.to_s} successes and #{(cntr - success_cntr).to_s} failures."
  end

  def down
    remove_column :plant_lines, :taxonomy_term_id
  end

end