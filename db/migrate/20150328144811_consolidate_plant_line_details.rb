class ConsolidatePlantLineDetails < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up

    # Rename existing PV to avoid naming clash
    execute("ALTER TABLE plant_varieties \
      RENAME TO old_plant_varieties")

    create_table :plant_varieties do |t|
      t.string :plant_variety_name,         primary: true
      t.string :crop_type
      t.string :comments
      t.text :entered_by_whom
      t.date :date_entered
      t.string :data_provenance

      t.string :data_attribution,           default: "unspecified", null: false
      t.string :country_of_origin,          default: "xxx", null: false
      t.string :country_registered,         default: "xxx", null: false
      t.string :year_registered,            default: "xxxx", null: false
      t.string :breeders_variety_code
      t.string :owner
      t.string :quoted_parentage
      t.string :female_parent
      t.string :male_parent
    end

    pv_ctr = 0
    pvd_ctr = 0

    result = execute("SELECT * FROM old_plant_varieties")
    result.each do |row|
      pv_ctr += 1

      pvd = execute("SELECT * FROM plant_variety_detail
        WHERE plant_variety_name = E'#{escape(row['plant_variety_name'])}'").first

      insert = "INSERT INTO plant_varieties \
        (plant_variety_name, crop_type, comments, entered_by_whom, \
        date_entered, data_provenance"

      unless pvd.blank?
        pvd_ctr+=1
        insert+= ", data_attribution, country_of_origin, country_registered, \
          year_registered, breeders_variety_code, owner, quoted_parentage, \
          female_parent, male_parent"
      end

      # Merge 'comments', 'entered_by_whom', 'date_entered' and 'data_provenance'
      tgt_comments = row['comments']
      tgt_entered_by_whom = row['entered_by_whom']
      tgt_date_entered = row['date_entered']
      tgt_data_provenance = row['data_provenance']

      unless pvd.blank?
        # Override pv.comments with pvd.comments
        tgt_comments = pvd['comments'] unless pvd['comments'].blank?
        # Override pv.data_provenance with pvd.data_provenance
        tgt_data_provenance = pvd['data_provenance'] unless pvd['data_provenance'].blank?
        # Keep pv.date_entered as it is identical with pvd.date_entered
        # Replace pv.entered_by_whom with pvd.entered_by_whom if longer
        if pvd['entered_by_whom'].length > tgt_entered_by_whom.length
          tgt_entered_by_whom = pvd['entered_by_whom']
        end
      end

      insert += ") VALUES (
        E'#{escape(row['plant_variety_name'])}', \
        '#{row['crop_type']}', \
        '#{tgt_comments}', \
        '#{tgt_entered_by_whom}', \
        '#{tgt_date_entered}', \
        '#{tgt_data_provenance}'"

      unless pvd.blank?
        insert+=", \
          '#{pvd['data_attribution']}', \
          '#{pvd['country_of_origin']}', \
          '#{pvd['country_registered']}', \
          '#{pvd['year_registered']}', \
          '#{pvd['breeders_variety_code']}', \
          E'#{escape(pvd['owner'])}', \
          '#{pvd['quoted_parentage']}', \
          '#{pvd['female_parent']}', \
          '#{pvd['male_parent']}'"
      end

      insert += ")"

      execute(insert)

    end

    puts "======================"
    puts "Processed #{pv_ctr.to_s} PV records and #{pvd_ctr.to_s} PVD records."
    puts "======================"

    drop_table :old_plant_varieties
    drop_table :plant_variety_detail

  end

  def down
    create_table "old_plant_varieties", id: false, force: :cascade do |t|
      t.text "plant_variety_name", primary: true
      t.text "genus",              default: "unspecified", null: false
      t.text "species",            default: "unspecified", null: false
      t.text "subtaxa"
      t.text "crop_type"
      t.text "comments"
      t.text "entered_by_whom",    default: "unspecified", null: false
      t.date "date_entered"
      t.text "data_provenance"
    end

    add_index "old_plant_varieties", ["plant_variety_name"], name: "idx_143909_plant_variety_name", using: :btree

    create_table "plant_variety_detail", id: false, force: :cascade do |t|
      t.text "plant_variety_name",    primary: true
      t.text "data_attribution",      default: "unspecified", null: false
      t.text "country_of_origin",     default: "xxx",         null: false
      t.text "country_registered",    default: "xxx",         null: false
      t.text "year_registered",       default: "xxxx",        null: false
      t.text "breeders_variety_code"
      t.text "owner"
      t.text "quoted_parentage"
      t.text "female_parent"
      t.text "male_parent"
      t.text "comments",                                      null: false
      t.text "entered_by_whom",       default: "unspecified", null: false
      t.date "date_entered"
      t.text "data_provenance"
    end

    add_index "plant_variety_detail", ["data_attribution"], name: "idx_143926_data_provenance", using: :btree
    add_index "plant_variety_detail", ["plant_variety_name"], name: "idx_143926_plant_variety_name", using: :btree

    pv_ctr = 0
    pvd_ctr = 0

    result = execute("SELECT * FROM plant_varieties")

    result.each do |pld|

      insert_pv = "INSERT INTO old_plant_varieties(plant_variety_name, genus, \
        species, subtaxa, crop_type, comments, entered_by_whom, date_entered, \
        data_provenance) VALUES ( \
        E'#{escape(pld['plant_variety_name'])}', \
        'unspecified', 'unspecified', 'unspecified', \
        '#{pld['crop_type']}', \
        '#{pld['comments']}', \
        '#{pld['entered_by_whom']}', \
        '#{pld['date_entered']}', \
        '#{pld['data_provenance']}')"

      execute(insert_pv)
      pv_ctr += 1

      unless pld['country_registered'] == 'xxx'
        insert_pvd = "INSERT INTO plant_variety_detail(plant_variety_name, \
          data_attribution, country_of_origin, country_registered, year_registered, \
          breeders_variety_code, owner, quoted_parentage, female_parent, \
          male_parent, comments, entered_by_whom, date_entered, \
          data_provenance) VALUES ( \
          E'#{escape(pld['plant_variety_name'])}', \
          '#{pld['data_attribution']}', \
          '#{pld['country_of_origin']}', \
          '#{pld['country_registered']}', \
          '#{pld['year_registered']}', \
          '#{pld['breeders_variety_code']}', \
          E'#{escape(pld['owner'])}', \
          '#{pld['quoted_parentage']}', \
          '#{pld['female_parent']}', \
          '#{pld['male_parent']}', \
          '#{pld['comments']}', \
          '#{pld['entered_by_whom']}', \
          '#{pld['date_entered']}', \
          '#{pld['data_provenance']}')"

        execute(insert_pvd)
        pvd_ctr += 1

      end

    end

    puts "======================"
    puts "Inserted #{pv_ctr.to_s} PV records and #{pvd_ctr.to_s} PVD records."
    puts "======================"

    drop_table :plant_varieties
    execute("ALTER TABLE old_plant_varieties \
      RENAME TO plant_varieties")
  end

end
