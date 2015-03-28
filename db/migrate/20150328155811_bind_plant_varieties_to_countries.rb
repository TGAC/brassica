class BindPlantVarietiesToCountries < ActiveRecord::Migration
  def up

    # Add index on countries for faster search
    add_index "countries", ["country_code"], name: 'idx_ccs_country_code', using: :btree

    # Grab all existing country codes
    ccs = ActiveRecord::Base.connection.execute("SELECT country_code FROM countries")
    ccs = ccs.collect { |cc| cc['country_code'] }

    create_table "plant_variety_country_of_origin", id: false, force: :cascade do |t|
      t.string :plant_variety_name
      t.string :country_code
    end

    # Iterate over PVs and try to assign each to the appropriate countries
    pvs = ActiveRecord::Base.connection.execute("SELECT * FROM plant_varieties")

    pvs.each do |pv|
      coo = pv['country_of_origin'].delete(' ').upcase
      next if coo=='XXX'

      #puts "Analyzing #{coo}"
      codes = coo.split(';')
      codes.each do |code|
        code = data_fixes(code)
        if ccs.include? code
          insert = "INSERT INTO plant_variety_country_of_origin( \
            plant_variety_name, country_code) VALUES ( \
            '#{pv['plant_variety_name']}', \
            '#{code}')"
          ActiveRecord::Base.connection.execute(insert)
        else
          puts "Unknown code #{code}. Giving up."
        end
      end
    end

    #Now do the same for country_registered
    create_table "plant_variety_country_registered", id: false, force: :cascade do |t|
      t.string :plant_variety_name
      t.string :country_code
    end

    pvs.each do |pv|
      cr = pv['country_registered'].delete(' ').upcase
      next if cr == 'XXX'

      codes=cr.split(/[\/\;]/)
      codes.each do |code|
        code = data_fixes(code)
        if ccs.include? code
          insert = "INSERT INTO plant_variety_country_registered( \
            plant_variety_name, country_code) VALUES ( \
            '#{pv['plant_variety_name']}', \
            '#{code}')"
          ActiveRecord::Base.connection.execute(insert)
        else
          puts "Unknown code #{code}. Giving up."
        end
      end

    end


  end

  def down
    drop_table :plant_variety_country_of_origin
    drop_table :plant_variety_country_registered
    remove_index(:countries, :name => 'idx_ccs_country_code')
  end

  def data_fixes(code)
    {
        'CHINA' => 'CHN',
        'AUSTRALIA' => 'AUS',
        'FINLAND' => 'FIN',
        'UKRAINE' => 'UKR',
        'LATVIA' => 'LVA',
        'CHILE' => 'CHL',
        'JAPAN' => 'JPN',
        'INDIA' => 'IND',
        'RUSSIA' => 'RUS',
        'ESTONIA' => 'EST',
        'SPA' => 'ESP',
        'LIT' => 'LTU',
        'LAT' => 'LVA',
        'BRD' => 'DEU',
        'GBBR' => 'GBR'
    }.each do |from,to|
      code = code.gsub(from, to)
    end
    if code == 'GB'
      code = 'GBR'
    end
    code
  end


end
