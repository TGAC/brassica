require 'csv'

namespace :curate do
  desc 'Fix link between plant scoring units and plant accessions on the basis of cs_full_web data'
  task psus_accessions: :environment do

    # Import CSV
    cs = {}

    counter = 0

    CSV.foreach("db/psus_accessions.csv") do |row|
      cs[row[0]] = row[1]
      counter += 1
    end

    puts "#{counter} plant scoring units imported."

    psus = PlantScoringUnit.all
    processed = 0
    conflicts = 0
    psus.each do |psu|
      processed += 1

      unless psu.plant_accession.nil?
        psu_acc = psu.plant_accession.plant_accession
        psu_cs_acc = cs[psu.scoring_unit_name]

        if psu_acc != psu_cs_acc
          conflicts += 1
          # Find correct plant accession
          pas = PlantAccession.where(plant_accession: cs[psu.scoring_unit_name]).all
          if pas.length > 1
            puts "ERROR: ambiguous plant accession name: #{cs[psu.scoring_unit_name]}: #{pas.length} records detected."
          elsif pas.length == 0
            puts "ERROR: plant accession #{cs[psu.scoring_unit_name]} not present in database."
          else
            psu.plant_accession = pas.first
            psu.save
          end
        end
      end

      if processed % 100 == 0
        puts "#{processed}..."
      end
    end

    puts "All done. ##{processed} records processed; #{conflicts} conflicts detected."

  end
end
