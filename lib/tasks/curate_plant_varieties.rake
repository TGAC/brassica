require 'csv'

namespace :curate do
  desc 'Curate names of plant varieties based on data received from TGAC'
  task plant_varieties: :environment do

    # Import CSV
    list = {}
    CSV.foreach("db/new_cultivars.csv", {col_sep: '#'}) do |row|
      list[row[1]] = row[0]
    end




    pl_nov = PlantLine.where("plant_variety_id IS NULL").all
    puts "#{PlantLine.count} plant lines present (#{pl_nov.length} with no assigned variety)."

    pv_nol = PlantVariety.where(plant_lines: []).all
    puts "#{PlantVariety.count} plant varieties present (#{pv_nol.length} with no assigned lines)."



    pl_syn_created = 0
    pl_name_created = 0
    pv_syn_created = 0

    CSV.foreach("db/new_cultivars.csv", {col_sep: '#'}) do |row|
      #puts "Processing PV #{row[1]} with synonym #{row[0]}"

      # Attempt to find PlantLine with synonym as name
      pls = PlantLine.where(plant_line_name: row[0]).all
      if pls.count > 1
        puts "WARNING! #{pls.count} plant lines found with #{row[0]} as name."
      end
      pls.each do |pl|
        # upsert proper plant_variety for this PL
        pv = PlantVariety.find_or_create_by(plant_variety_name: row[1]) do |obj|
          puts "No matching PV object found for name #{row[1]}. Creating..."
          obj.comments = "Automatically created by PlantVariety creation script based on TGAC PV data."
          obj.date_entered = Date.today
          obj.synonyms = row[0]
          pl_syn_created += 1
        end
        pv.save
        unless pv.errors.blank?
          puts "UNABLE TO SAVE PV #{row[1]} DUE TO ERRORS: #{pv.errors.inspect}"
        end
        pl.plant_variety = pv
        pl.save
      end
    end

    CSV.foreach("db/new_cultivars.csv", {col_sep: '#'}) do |row|

      # Attempt to find PlantLine with name as name
      pls = PlantLine.where(plant_line_name: row[1]).all
      if pls.count > 1
        puts "WARNING! #{pls.count} plant lines found with #{row[1]} as name."
      end
      pls.each do |pl|
        # upsert proper plant_variety for this PL
        pv = PlantVariety.find_or_create_by(plant_variety_name: row[1]) do |obj|
          puts "No matching PV object found for name #{row[1]}. Creating..."
          obj.comments = "Automatically created by PlantVariety creation script based on TGAC PV data."
          obj.date_entered = Date.today
          obj.synonyms = row[0]
          pl_name_created += 1
        end
        pv.save
        unless pv.errors.blank?
          puts "UNABLE TO SAVE PV #{row[1]} DUE TO ERRORS: #{pv.errors.inspect}"
        end
        pl.plant_variety = pv
        pl.save
      end
    end


    puts "======================"


    CSV.foreach("db/new_cultivars.csv", {col_sep: '#'}) do |row|
      #puts "Processing PV #{row[1]} with synonym #{row[0]}"
      # Attempt to find PlantVariety with synonym as name
      pvs = PlantVariety.where(plant_variety_name: row[0]).all
      if pvs.count > 1
        puts "WARNING! #{pvs.count} plant varieties found with #{row[0]} as name."
      end
      pvs.each do |pv|
        # upsert proper plant_variety for this PV
        pv_new = PlantVariety.find_or_create_by(plant_variety_name: row[1]) do |obj|
          puts "No matching PV object found for name #{row[1]}. Creating..."
          obj.comments = "Automatically created by PlantVariety creation script based on TGAC PV data."
          obj.date_entered = Date.today
          obj.synonyms = row[0]
          pv_syn_created += 1
        end
        pv_new.plant_lines = pv.plant_lines
        pv_new.save
        unless pv_new.errors.blank?
          puts "UNABLE TO SAVE PV #{row[1]} DUE TO ERRORS: #{pv_new.errors.inspect}"
        end

        delete_if_empty(pv.reload)

      end
    end



    # Now expunge orphaned PVs, test if all PV names listed in AME's list are represented, and check whether any other PVs (not on list) still exist with attached PLs.

    # Expunge orphaned PVs.
    puts "Checking for orphaned plant varieties..."
    pvs = PlantVariety.where(plant_lines: []).all
    puts "#{pvs.length} orphaned plant varieties found."
    pvs.each do |pv|
      pv.destroy
    end

    # Test if PVs listed in AME's list are represented

    unrepresented_pv = 0
    represented_pv = 0

    CSV.foreach("db/new_cultivars.csv", {col_sep: '#'}) do |row|
      #puts "Processing PV #{row[1]} with synonym #{row[0]}"

      pv = PlantVariety.find_by(plant_variety_name: row[1])
      if pv.blank?
        #puts "WARNING! No plant variety with name #{row[1]} found in DB!"
        unrepresented_pv += 1
        new_pv = PlantVariety.new(plant_variety_name: row[1])
        new_pv.save
      else
        represented_pv += 1
      end
    end

    puts "Created #{pl_syn_created} PVs for PL SYN, #{pl_name_created} PVs for PL NAME and #{pv_syn_created} PVs for PV SYN."

    puts "#{represented_pv} AME plant varieties found in DB."
    puts "#{unrepresented_pv} AME plant varieties not found in DB."

    pl_nov = PlantLine.where("plant_variety_id IS NULL").all
    puts "#{PlantLine.count} plant lines present (#{pl_nov.length} with no assigned variety)."

    pv_nol = PlantVariety.where(plant_lines: []).all
    puts "#{PlantVariety.count} plant varieties present (#{pv_nol.length} with no assigned lines)."



    # Also add synonyms to all new PVs.

    PlantVariety.all.each do |pv|
      if list.keys.include? pv.plant_variety_name
        add_synonym_if_not_present(pv, list[pv.plant_variety_name])
      end

      pv.plant_lines.each do |pl|
        add_synonym_if_not_present(pv, pl.plant_line_name)
      end

      pv.save
    end

    #puts "All done. ##{processed} records processed; #{conflicts} conflicts detected."
  end

  def delete_if_empty(pv)
    pv.reload
    if pv.plant_lines.count == 0
      puts "Deleting empty pv #{pv.plant_variety_name}"
      pv.delete
    end
  end

  def add_synonym_if_not_present(pv, synonym)
    synonyms = pv.synonyms.split('###')
    synonyms << synonym unless synonyms.include? synonym
    pv.synonyms = synonyms.join('###')
    pv.save
  end


end
