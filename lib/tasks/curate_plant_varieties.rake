require 'csv'

namespace :curate do
  desc 'Curate names of plant varieties based on data received from TGAC'
  task plant_varieties: :environment do

    # Rebuild ES index for PlantVarieties to prevent errors when destroying objects
    PlantVariety.import force: true, refresh: true

    # Fix some simple errors in PVs
    pvs = PlantVariety.where("plant_variety_name LIKE '%quell%'").all
    if pvs.count == 3
      pvs.each do |pv|
        pv.plant_variety_name = 'Gülzower Ölquell'
        pv.save
      end
    end

    puts "#{PlantVariety.count} plant varieties registered in DB."

    # Destroy all PVs except those which are linked to PlantLines
#    pvs = PlantVariety.where(plant_lines: []).all
    pvs = PlantVariety.unscoped.includes(:plant_lines).where( plant_lines: { plant_variety_id: nil } )

    puts "Found #{pvs.count} plant varieties with no associated lines. Purging."
    pvs.destroy_all

    puts "#{PlantVariety.count} plant varieties remain."

    # Import CSV
    puts "Processing export file and spawning new plant variety objects..."
    import_counter = 0
    import_errors = 0
    CSV.foreach("db/new_cultivars.csv", {col_sep: '#'}) do |row|
      # Assuming row[0] is synonym; row[1] is real name
      # upsert new proper plant_variety
      pv = PlantVariety.find_or_create_by(plant_variety_name: row[1]) do |obj|
      # puts "No matching PV object found for name #{row[1]}. Creating..."
        obj.comments = 'Automatically created by PlantVariety creation script based on TGAC PV data.'
        obj.entered_by_whom = 'BIP'
        obj.date_entered = Date.today
        obj.synonyms << row[0]
      end
      import_counter += 1

      unless pv.errors.blank?
        import_errors += 1
      end

      # Look for plant_lines whose names match this plant_variety's official name
      pls = PlantLine.where(plant_line_name: row[1]).all
      if pls.count > 1
        puts "#{pls.count} plant lines found with #{row[1]} as name. Reassigning to newly created PV."
      end

      pls.each do |pl|
        pl.plant_variety = pv
        pl.save
      end

      # Look for plant_lines whose names match this plant_variety's synonym
      pls = PlantLine.where(plant_line_name: row[0]).all
      if pls.count > 1
        puts "#{pls.count} plant lines found with #{row[0]} as name. Reassigning to newly created PV."
      end

      pls.each do |pl|
        pl.plant_variety = pv
        pl.save
      end
    end

    puts "Import complete. #{import_counter} records processed (with #{import_errors} errors)."

    # Expunge orphaned PVs.
    puts "Checking for orphaned plant varieties..."
    pvs = PlantVariety.unscoped.includes(:plant_lines).where( plant_lines: { plant_variety_id: nil } ).where("plant_varieties.entered_by_whom != 'BIP'")
    puts "#{pvs.length} orphaned plant varieties found."
    pvs.destroy_all

    puts "All done. #{PlantVariety.count} plant varieties now present in DB "\
      "(#{PlantVariety.where("entered_by_whom != 'BIP'").count} existing and "\
      "#{PlantVariety.where("entered_by_whom = 'BIP'").count} imported). "\
      "#{PlantLine.where("plant_variety_id IS NOT NULL").count} plant lines "\
      "(of #{PlantLine.count}) have an assigned plant variety."
  end
end
