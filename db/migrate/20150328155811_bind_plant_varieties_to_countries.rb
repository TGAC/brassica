class BindPlantVarietiesToCountries < ActiveRecord::Migration
  def up

    # Add index on countries for faster search
    add_index "countries", ["country_code"], name: 'idx_ccs_country_code', using: :btree

    ActiveRecord::Base.connection.execute("DELETE FROM countries WHERE \
      country_code IN ('xxx', 'n/a', 'ooo')")

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
          # Add notification to comments
          puts "Unknown code #{code}. Inserting warning in comments."
          comments = pv['comments']
          comments = comments.blank? ? '' : comments
          comments += " | WARNING: Unrecognized country_of_origin: #{code}"
          update = "UPDATE plant_varieties SET comments = '#{comments}' \
            WHERE plant_variety_name = '#{escape(pv['plant_variety_name'])}'"
          ActiveRecord::Base.connection.execute(update)
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
          # Add notification to comments
          puts "Unknown code #{code}. Inserting warning in comments."
          comments = pv['comments']
          comments = comments.blank? ? '' : comments
          comments += " | WARNING: Unrecognized country_registered: #{code}"
          update = "UPDATE plant_varieties SET comments = '#{comments}' \
            WHERE plant_variety_name = '#{escape(pv['plant_variety_name'])}'"
          ActiveRecord::Base.connection.execute(update)
        end
      end

    end

    remove_column :plant_varieties, :country_of_origin
    remove_column :plant_varieties, :country_registered

  end

  def down
    add_column :plant_varieties, :country_of_origin, :string, default: ''
    add_column :plant_varieties, :country_registered, :string, default: ''

    pvs = ActiveRecord::Base.connection.execute("SELECT * FROM plant_varieties")
    pvs.each do |pv|
      pv_coo = ""
      pv_cr = ""
      coos = ActiveRecord::Base.connection.execute("SELECT country_code FROM \
        plant_variety_country_of_origin WHERE plant_variety_name = \
        E'#{escape(pv['plant_variety_name'])}'")
      crs = ActiveRecord::Base.connection.execute("SELECT country_code FROM \
        plant_variety_country_registered WHERE plant_variety_name = \
        E'#{escape(pv['plant_variety_name'])}'")
      pv_coo = (coos.collect {|coo| coo['country_code']}.join('; '))
      pv_cr = (crs.collect {|cr| cr['country_code']}.join('; '))

      unless pv_coo.blank?
        update = "UPDATE plant_varieties SET country_of_origin = '#{pv_coo}' \
          WHERE plant_variety_name = '#{escape(pv['plant_variety_name'])}'"
        ActiveRecord::Base.connection.execute(update)
      end
      unless pv_cr.blank?
        update = "UPDATE plant_varieties SET country_registered = '#{pv_cr}' \
          WHERE plant_variety_name = '#{escape(pv['plant_variety_name'])}'"
        ActiveRecord::Base.connection.execute(update)
      end
    end


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

  def escape(string)
    if string.nil?
      nil
    else
      pattern = /(\'|\"|\.|\*|\/|\-|\\|\)|\$|\+|\(|\^|\?|\!|\~|\`)/
      string.gsub(pattern){|match|"\\"  + match}
    end
  end
end
