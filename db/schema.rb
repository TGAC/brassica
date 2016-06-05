# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160605160419) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "api_keys", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token",      null: false
    t.integer  "user_id",    null: false
  end

  add_index "api_keys", ["token"], name: "index_api_keys_on_token", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "country_code", limit: 3, null: false
    t.text     "country_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["country_code"], name: "countries_country_code_idx", using: :btree

  create_table "design_factors", force: :cascade do |t|
    t.text     "design_factor_name",  null: false
    t.text     "institute_id",        null: false
    t.text     "trial_location_name", null: false
    t.text     "design_unit_counter", null: false
    t.text     "design_factor_1"
    t.text     "design_factor_2"
    t.text     "design_factor_3"
    t.text     "design_factor_4"
    t.text     "design_factor_5"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "design_factors", ["design_factor_name"], name: "design_factors_design_factor_name_idx", using: :btree
  add_index "design_factors", ["institute_id"], name: "idx_143500_institute_id", using: :btree

  create_table "genotype_matrices", force: :cascade do |t|
    t.text     "matrix_compiled_by",       null: false
    t.text     "original_file_name",       null: false
    t.date     "date_matrix_available"
    t.text     "number_markers_in_matrix", null: false
    t.text     "number_lines_in_matrix",   null: false
    t.text     "matrix",                   null: false
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.integer  "linkage_map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genotype_matrices", ["linkage_map_id"], name: "genotype_matrices_linkage_map_id_idx", using: :btree

  create_table "linkage_groups", force: :cascade do |t|
    t.text     "linkage_group_label",                        null: false
    t.text     "linkage_group_name",                         null: false
    t.text     "total_length"
    t.text     "lod_threshold"
    t.text     "consensus_group_assignment",                 null: false
    t.text     "consensus_group_orientation"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "map_positions_count",         default: 0,    null: false
    t.integer  "map_locus_hits_count",        default: 0,    null: false
    t.integer  "linkage_map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "qtls_count",                  default: 0,    null: false
    t.boolean  "published",                   default: true, null: false
    t.datetime "published_on"
  end

  add_index "linkage_groups", ["linkage_group_label"], name: "linkage_groups_linkage_group_label_idx", using: :btree
  add_index "linkage_groups", ["linkage_group_name"], name: "idx_143534_linkage_group_name", using: :btree
  add_index "linkage_groups", ["published"], name: "index_linkage_groups_on_published", using: :btree
  add_index "linkage_groups", ["user_id"], name: "index_linkage_groups_on_user_id", using: :btree

  create_table "linkage_maps", force: :cascade do |t|
    t.text     "linkage_map_label",                             null: false
    t.text     "linkage_map_name",                              null: false
    t.string   "map_version_no",       limit: 3
    t.date     "map_version_date"
    t.text     "mapping_software"
    t.text     "mapping_function"
    t.text     "map_author"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "plant_population_id"
    t.integer  "pubmed_id"
    t.integer  "map_locus_hits_count",           default: 0,    null: false
    t.integer  "linkage_groups_count",           default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",                      default: true, null: false
    t.datetime "published_on"
  end

  add_index "linkage_maps", ["linkage_map_label"], name: "linkage_maps_linkage_map_label_idx", using: :btree
  add_index "linkage_maps", ["plant_population_id"], name: "linkage_maps_plant_population_id_idx", using: :btree
  add_index "linkage_maps", ["published"], name: "index_linkage_maps_on_published", using: :btree
  add_index "linkage_maps", ["user_id"], name: "index_linkage_maps_on_user_id", using: :btree

  create_table "map_locus_hits", force: :cascade do |t|
    t.text     "consensus_group_assignment",                null: false
    t.text     "canonical_marker_name",                     null: false
    t.text     "map_position"
    t.text     "associated_sequence_id",                    null: false
    t.text     "sequence_source_acronym",                   null: false
    t.text     "atg_hit_seq_id"
    t.text     "atg_hit_seq_source"
    t.text     "bac_hit_seq_id"
    t.text     "bac_hit_seq_source"
    t.text     "bac_hit_name"
    t.integer  "linkage_map_id"
    t.integer  "linkage_group_id"
    t.integer  "population_locus_id"
    t.integer  "map_position_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "entered_by_whom"
    t.date     "date_entered"
    t.boolean  "published",                  default: true, null: false
    t.datetime "published_on"
  end

  add_index "map_locus_hits", ["linkage_group_id"], name: "map_locus_hits_linkage_group_id_idx", using: :btree
  add_index "map_locus_hits", ["linkage_map_id"], name: "map_locus_hits_linkage_map_id_idx", using: :btree
  add_index "map_locus_hits", ["map_position_id"], name: "map_locus_hits_map_position_id_idx", using: :btree
  add_index "map_locus_hits", ["population_locus_id"], name: "map_locus_hits_population_locus_id_idx", using: :btree
  add_index "map_locus_hits", ["published"], name: "index_map_locus_hits_on_published", using: :btree
  add_index "map_locus_hits", ["user_id"], name: "index_map_locus_hits_on_user_id", using: :btree

  create_table "map_positions", force: :cascade do |t|
    t.text     "marker_assay_name"
    t.text     "mapping_locus"
    t.text     "map_position"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "linkage_group_id"
    t.integer  "population_locus_id"
    t.integer  "map_locus_hits_count", default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "marker_assay_id"
    t.boolean  "published",            default: true, null: false
    t.datetime "published_on"
  end

  add_index "map_positions", ["linkage_group_id"], name: "map_positions_linkage_group_id_idx", using: :btree
  add_index "map_positions", ["map_position"], name: "idx_143597_map_position", using: :btree
  add_index "map_positions", ["mapping_locus"], name: "map_positions_mapping_locus_idx", using: :btree
  add_index "map_positions", ["marker_assay_id"], name: "map_positions_marker_assay_id_idx", using: :btree
  add_index "map_positions", ["marker_assay_name"], name: "map_positions_marker_assay_name_idx", using: :btree
  add_index "map_positions", ["population_locus_id"], name: "map_positions_population_locus_id_idx", using: :btree
  add_index "map_positions", ["published"], name: "index_map_positions_on_published", using: :btree
  add_index "map_positions", ["user_id"], name: "index_map_positions_on_user_id", using: :btree

  create_table "marker_assays", force: :cascade do |t|
    t.text     "marker_assay_name",                            null: false
    t.text     "canonical_marker_name",                        null: false
    t.text     "marker_type"
    t.text     "primer_a_name"
    t.text     "primer_b_name"
    t.text     "separation_system"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "restriction_enzyme_a_id"
    t.integer  "marker_sequence_assignment_id"
    t.integer  "restriction_enzyme_b_id"
    t.integer  "primer_a_id"
    t.integer  "primer_b_id"
    t.integer  "probe_id"
    t.integer  "population_loci_count",         default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "map_positions_count",           default: 0,    null: false
    t.boolean  "published",                     default: true, null: false
    t.datetime "published_on"
  end

  add_index "marker_assays", ["canonical_marker_name"], name: "marker_assays_canonical_marker_name_idx", using: :btree
  add_index "marker_assays", ["marker_assay_name"], name: "marker_assays_marker_assay_name_idx", using: :btree
  add_index "marker_assays", ["marker_sequence_assignment_id"], name: "marker_assays_marker_sequence_assignment_id_idx", using: :btree
  add_index "marker_assays", ["primer_a_id"], name: "marker_assays_primer_a_id_idx", using: :btree
  add_index "marker_assays", ["primer_a_name"], name: "marker_assays_primer_a_idx", using: :btree
  add_index "marker_assays", ["primer_b_id"], name: "marker_assays_primer_b_id_idx", using: :btree
  add_index "marker_assays", ["primer_b_name"], name: "marker_assays_primer_b_idx", using: :btree
  add_index "marker_assays", ["probe_id"], name: "marker_assays_probe_id_idx", using: :btree
  add_index "marker_assays", ["published"], name: "index_marker_assays_on_published", using: :btree
  add_index "marker_assays", ["user_id"], name: "index_marker_assays_on_user_id", using: :btree

  create_table "marker_sequence_assignments", force: :cascade do |t|
    t.text     "marker_set",              null: false
    t.text     "canonical_marker_name",   null: false
    t.text     "associated_sequence_id"
    t.text     "sequence_source_acronym"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "marker_sequence_assignments", ["canonical_marker_name"], name: "marker_sequence_assignments_canonical_marker_name_idx", using: :btree

  create_table "plant_accessions", force: :cascade do |t|
    t.text     "plant_accession",                           null: false
    t.text     "plant_accession_derivation"
    t.text     "accession_originator"
    t.text     "originating_organisation"
    t.text     "year_produced"
    t.date     "date_harvested"
    t.text     "female_parent_plant_id"
    t.text     "male_parent_plant_id"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "plant_line_id"
    t.integer  "plant_scoring_units_count",  default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",                  default: true, null: false
    t.datetime "published_on"
    t.integer  "plant_variety_id"
  end

  add_index "plant_accessions", ["plant_accession"], name: "plant_accessions_plant_accession_idx", using: :btree
  add_index "plant_accessions", ["plant_line_id"], name: "plant_accessions_plant_line_id_idx", using: :btree
  add_index "plant_accessions", ["plant_variety_id"], name: "index_plant_accessions_on_plant_variety_id", using: :btree
  add_index "plant_accessions", ["published"], name: "index_plant_accessions_on_published", using: :btree
  add_index "plant_accessions", ["user_id"], name: "index_plant_accessions_on_user_id", using: :btree

  create_table "plant_lines", force: :cascade do |t|
    t.text     "plant_line_name",                    null: false
    t.text     "common_name"
    t.text     "plant_variety_name"
    t.text     "named_by_whom"
    t.text     "organisation"
    t.text     "genetic_status"
    t.text     "previous_line_name"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "taxonomy_term_id"
    t.integer  "plant_variety_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",           default: true, null: false
    t.string   "sequence_identifier"
    t.datetime "published_on"
  end

  add_index "plant_lines", ["plant_line_name"], name: "plant_lines_plant_line_name_idx", using: :btree
  add_index "plant_lines", ["plant_variety_id"], name: "plant_lines_plant_variety_id_idx", using: :btree
  add_index "plant_lines", ["plant_variety_name"], name: "idx_143729_plant_variety", using: :btree
  add_index "plant_lines", ["published"], name: "index_plant_lines_on_published", using: :btree
  add_index "plant_lines", ["taxonomy_term_id"], name: "index_plant_lines_on_taxonomy_term_id", using: :btree
  add_index "plant_lines", ["user_id"], name: "index_plant_lines_on_user_id", using: :btree

  create_table "plant_parts", force: :cascade do |t|
    t.text     "plant_part",                              null: false
    t.text     "description"
    t.text     "described_by_whom"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "confirmed_by_whom"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",             default: "CROPSTORE", null: false
    t.boolean  "canonical",         default: false,       null: false
  end

  add_index "plant_parts", ["plant_part"], name: "plant_parts_plant_part_idx", using: :btree

  create_table "plant_population_lists", force: :cascade do |t|
    t.text     "sort_order"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "confirmed_by_whom"
    t.integer  "plant_line_id"
    t.integer  "plant_population_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",           default: true, null: false
    t.datetime "published_on"
  end

  add_index "plant_population_lists", ["plant_line_id", "plant_population_id"], name: "unique_ppl_idx", unique: true, using: :btree
  add_index "plant_population_lists", ["plant_line_id"], name: "plant_population_lists_plant_line_id_idx", using: :btree
  add_index "plant_population_lists", ["plant_population_id"], name: "plant_population_lists_plant_population_id_idx", using: :btree
  add_index "plant_population_lists", ["published"], name: "index_plant_population_lists_on_published", using: :btree
  add_index "plant_population_lists", ["user_id"], name: "index_plant_population_lists_on_user_id", using: :btree

  create_table "plant_populations", force: :cascade do |t|
    t.text     "name",                                        null: false
    t.text     "population_type"
    t.text     "canonical_population_name"
    t.text     "description"
    t.date     "date_established"
    t.text     "established_by_whom"
    t.text     "establishing_organisation"
    t.text     "population_owned_by"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_owned_by"
    t.text     "data_provenance"
    t.text     "confirmed_by_whom"
    t.text     "assigned_population_name"
    t.integer  "taxonomy_term_id"
    t.integer  "male_parent_line_id"
    t.integer  "female_parent_line_id"
    t.integer  "population_type_id"
    t.integer  "plant_population_lists_count", default: 0,    null: false
    t.integer  "linkage_maps_count",           default: 0,    null: false
    t.integer  "plant_trials_count",           default: 0,    null: false
    t.integer  "population_loci_count",        default: 0,    null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                    default: true, null: false
    t.datetime "published_on"
  end

  add_index "plant_populations", ["female_parent_line_id"], name: "plant_populations_female_parent_line_id_idx", using: :btree
  add_index "plant_populations", ["male_parent_line_id"], name: "plant_populations_male_parent_line_id_idx", using: :btree
  add_index "plant_populations", ["name"], name: "plant_populations_name_idx", using: :btree
  add_index "plant_populations", ["population_type"], name: "plant_populations_population_type_idx", using: :btree
  add_index "plant_populations", ["population_type_id"], name: "plant_populations_population_type_id_idx", using: :btree
  add_index "plant_populations", ["published"], name: "index_plant_populations_on_published", using: :btree
  add_index "plant_populations", ["taxonomy_term_id"], name: "index_plant_populations_on_taxonomy_term_id", using: :btree
  add_index "plant_populations", ["user_id"], name: "index_plant_populations_on_user_id", using: :btree

  create_table "plant_scoring_units", force: :cascade do |t|
    t.text     "scoring_unit_name",                       null: false
    t.text     "number_units_scored"
    t.text     "scoring_unit_sample_size"
    t.text     "scoring_unit_frame_size"
    t.date     "date_planted"
    t.text     "described_by_whom"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "plant_accession_id"
    t.integer  "plant_trial_id"
    t.integer  "design_factor_id"
    t.integer  "trait_scores_count",       default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",                default: true, null: false
    t.datetime "published_on"
  end

  add_index "plant_scoring_units", ["design_factor_id"], name: "plant_scoring_units_design_factor_id_idx", using: :btree
  add_index "plant_scoring_units", ["plant_accession_id"], name: "plant_scoring_units_plant_accession_id_idx", using: :btree
  add_index "plant_scoring_units", ["plant_trial_id"], name: "plant_scoring_units_plant_trial_id_idx", using: :btree
  add_index "plant_scoring_units", ["published"], name: "index_plant_scoring_units_on_published", using: :btree
  add_index "plant_scoring_units", ["scoring_unit_name"], name: "plant_scoring_units_scoring_unit_name_idx", using: :btree
  add_index "plant_scoring_units", ["user_id"], name: "index_plant_scoring_units_on_user_id", using: :btree

  create_table "plant_trials", force: :cascade do |t|
    t.text     "plant_trial_name",                         null: false
    t.text     "project_descriptor",                       null: false
    t.text     "plant_trial_description"
    t.text     "trial_year"
    t.text     "institute_id"
    t.text     "trial_location_site_name"
    t.text     "place_name"
    t.text     "latitude"
    t.text     "longitude"
    t.text     "altitude"
    t.text     "terrain"
    t.text     "soil_type"
    t.text     "contact_person"
    t.text     "design_type"
    t.text     "statistical_factors"
    t.text     "design_factors"
    t.text     "design_layout_matrix"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "country_id"
    t.integer  "plant_population_id"
    t.integer  "pubmed_id"
    t.integer  "plant_scoring_units_count", default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",                 default: true, null: false
    t.datetime "published_on"
  end

  add_index "plant_trials", ["country_id"], name: "plant_trials_country_id_idx", using: :btree
  add_index "plant_trials", ["plant_trial_name"], name: "plant_trials_plant_trial_name_idx", using: :btree
  add_index "plant_trials", ["published"], name: "index_plant_trials_on_published", using: :btree
  add_index "plant_trials", ["user_id"], name: "index_plant_trials_on_user_id", using: :btree

  create_table "plant_varieties", force: :cascade do |t|
    t.string   "plant_variety_name"
    t.string   "crop_type"
    t.string   "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.string   "data_provenance"
    t.string   "data_attribution"
    t.string   "year_registered"
    t.string   "breeders_variety_code"
    t.string   "owner"
    t.string   "quoted_parentage"
    t.string   "female_parent"
    t.string   "male_parent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",             default: true, null: false
    t.datetime "published_on"
  end

  add_index "plant_varieties", ["published"], name: "index_plant_varieties_on_published", using: :btree
  add_index "plant_varieties", ["user_id"], name: "index_plant_varieties_on_user_id", using: :btree

  create_table "plant_variety_country_of_origin", id: false, force: :cascade do |t|
    t.integer "country_id"
    t.integer "plant_variety_id"
  end

  add_index "plant_variety_country_of_origin", ["country_id"], name: "plant_variety_country_of_origin_country_id_idx", using: :btree
  add_index "plant_variety_country_of_origin", ["plant_variety_id", "country_id"], name: "unique_pv_coo_idx", unique: true, using: :btree
  add_index "plant_variety_country_of_origin", ["plant_variety_id"], name: "plant_variety_country_of_origin_plant_variety_id_idx", using: :btree

  create_table "plant_variety_country_registered", id: false, force: :cascade do |t|
    t.integer "country_id"
    t.integer "plant_variety_id"
  end

  add_index "plant_variety_country_registered", ["country_id"], name: "plant_variety_country_registered_country_id_idx", using: :btree
  add_index "plant_variety_country_registered", ["plant_variety_id", "country_id"], name: "unique_pv_cr_idx", unique: true, using: :btree
  add_index "plant_variety_country_registered", ["plant_variety_id"], name: "plant_variety_country_registered_plant_variety_id_idx", using: :btree

  create_table "pop_type_lookup", force: :cascade do |t|
    t.text     "population_type",  null: false
    t.text     "population_class", null: false
    t.text     "assigned_by_whom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pop_type_lookup", ["population_type"], name: "pop_type_lookup_population_type_idx", using: :btree

  create_table "population_loci", force: :cascade do |t|
    t.text     "mapping_locus",                       null: false
    t.text     "defined_by_whom"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.integer  "plant_population_id"
    t.integer  "marker_assay_id"
    t.integer  "map_locus_hits_count", default: 0,    null: false
    t.integer  "map_positions_count",  default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",            default: true, null: false
    t.datetime "published_on"
  end

  add_index "population_loci", ["mapping_locus"], name: "population_loci_mapping_locus_idx", using: :btree
  add_index "population_loci", ["marker_assay_id"], name: "population_loci_marker_assay_id_idx", using: :btree
  add_index "population_loci", ["plant_population_id"], name: "population_loci_plant_population_id_idx", using: :btree
  add_index "population_loci", ["published"], name: "index_population_loci_on_published", using: :btree
  add_index "population_loci", ["user_id"], name: "index_population_loci_on_user_id", using: :btree

  create_table "primers", force: :cascade do |t|
    t.text     "primer",                                 null: false
    t.text     "sequence",                               null: false
    t.text     "sequence_id"
    t.text     "sequence_source_acronym"
    t.text     "description"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.integer  "marker_assays_a_count",   default: 0,    null: false
    t.integer  "marker_assays_b_count",   default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",               default: true, null: false
    t.datetime "published_on"
  end

  add_index "primers", ["primer"], name: "primers_primer_idx", using: :btree
  add_index "primers", ["published"], name: "index_primers_on_published", using: :btree
  add_index "primers", ["user_id"], name: "index_primers_on_user_id", using: :btree

  create_table "probes", force: :cascade do |t|
    t.text     "probe_name",                             null: false
    t.text     "clone_name",                             null: false
    t.date     "date_described"
    t.text     "sequence_id",                            null: false
    t.text     "sequence_source_acronym",                null: false
    t.text     "comments"
    t.text     "entered_by_whom"
    t.text     "data_provenance"
    t.integer  "taxonomy_term_id"
    t.integer  "marker_assays_count",     default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.date     "date_entered"
    t.boolean  "published",               default: true, null: false
    t.datetime "published_on"
  end

  add_index "probes", ["probe_name"], name: "probes_probe_name_idx", using: :btree
  add_index "probes", ["published"], name: "index_probes_on_published", using: :btree
  add_index "probes", ["taxonomy_term_id"], name: "probes_taxonomy_term_id_idx", using: :btree
  add_index "probes", ["user_id"], name: "index_probes_on_user_id", using: :btree

  create_table "processed_trait_datasets", force: :cascade do |t|
    t.text     "processed_trait_dataset_name", null: false
    t.text     "processed_dataset_id"
    t.text     "trait_percent_heritability"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.integer  "plant_trial_id"
    t.integer  "trait_descriptor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "processed_trait_datasets", ["plant_trial_id"], name: "processed_trait_datasets_plant_trial_id_idx", using: :btree
  add_index "processed_trait_datasets", ["processed_trait_dataset_name"], name: "processed_trait_datasets_processed_trait_dataset_name_idx", using: :btree
  add_index "processed_trait_datasets", ["trait_descriptor_id"], name: "processed_trait_datasets_trait_descriptor_id_idx", using: :btree

  create_table "qtl", force: :cascade do |t|
    t.text     "qtl_rank",                                  null: false
    t.text     "map_qtl_label"
    t.text     "outer_interval_start"
    t.text     "inner_interval_start"
    t.text     "qtl_mid_position",                          null: false
    t.text     "inner_interval_end"
    t.text     "outer_interval_end"
    t.text     "peak_value"
    t.text     "peak_p_value"
    t.text     "regression_p"
    t.text     "residual_p"
    t.text     "additive_effect"
    t.text     "genetic_variance_explained"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.integer  "processed_trait_dataset_id"
    t.integer  "qtl_job_id"
    t.integer  "linkage_group_id"
    t.integer  "pubmed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",                  default: true, null: false
    t.datetime "published_on"
  end

  add_index "qtl", ["linkage_group_id"], name: "qtl_linkage_group_id_idx", using: :btree
  add_index "qtl", ["processed_trait_dataset_id"], name: "qtl_processed_trait_dataset_id_idx", using: :btree
  add_index "qtl", ["published"], name: "index_qtl_on_published", using: :btree
  add_index "qtl", ["qtl_job_id"], name: "qtl_qtl_job_id_idx", using: :btree
  add_index "qtl", ["user_id"], name: "index_qtl_on_user_id", using: :btree

  create_table "qtl_jobs", force: :cascade do |t|
    t.text     "qtl_job_name",                                  null: false
    t.text     "linkage_map_label"
    t.text     "qtl_software",                                  null: false
    t.text     "qtl_method",                                    null: false
    t.text     "threshold_specification_method"
    t.text     "interval_type"
    t.text     "inner_confidence_threshold"
    t.text     "outer_confidence_threshold"
    t.text     "qtl_statistic_type"
    t.text     "described_by_whom"
    t.date     "date_run"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.integer  "qtls_count",                     default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "linkage_map_id"
    t.boolean  "published",                      default: true, null: false
    t.datetime "published_on"
  end

  add_index "qtl_jobs", ["linkage_map_id"], name: "qtl_jobs_linkage_map_id_idx", using: :btree
  add_index "qtl_jobs", ["linkage_map_label"], name: "qtl_jobs_linkage_map_label_idx", using: :btree
  add_index "qtl_jobs", ["published"], name: "index_qtl_jobs_on_published", using: :btree
  add_index "qtl_jobs", ["qtl_job_name"], name: "qtl_jobs_qtl_job_name_idx", using: :btree
  add_index "qtl_jobs", ["qtl_software", "qtl_method"], name: "idx_144140_qtl_software", using: :btree
  add_index "qtl_jobs", ["user_id"], name: "index_qtl_jobs_on_user_id", using: :btree

  create_table "restriction_enzymes", force: :cascade do |t|
    t.text     "restriction_enzyme", null: false
    t.text     "recognition_site",   null: false
    t.text     "data_provenance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submission_uploads", force: :cascade do |t|
    t.integer  "submission_id",     null: false
    t.integer  "upload_type",       null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "submission_uploads", ["submission_id"], name: "index_submission_uploads_on_submission_id", using: :btree

  create_table "submissions", force: :cascade do |t|
    t.integer  "user_id",                             null: false
    t.string   "step",                                null: false
    t.json     "content",             default: {},    null: false
    t.boolean  "finalized",           default: false, null: false
    t.integer  "submission_type",                     null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "submitted_object_id"
    t.boolean  "published",           default: false, null: false
  end

  add_index "submissions", ["finalized"], name: "index_submissions_on_finalized", using: :btree
  add_index "submissions", ["submission_type"], name: "index_submissions_on_submission_type", using: :btree
  add_index "submissions", ["user_id"], name: "index_submissions_on_user_id", using: :btree

  create_table "taxonomy_terms", force: :cascade do |t|
    t.string   "label",                           null: false
    t.string   "name",                            null: false
    t.integer  "taxonomy_term_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "canonical",        default: true
  end

  add_index "taxonomy_terms", ["label"], name: "index_taxonomy_terms_on_label", using: :btree
  add_index "taxonomy_terms", ["name"], name: "index_taxonomy_terms_on_name", unique: true, using: :btree
  add_index "taxonomy_terms", ["taxonomy_term_id"], name: "index_taxonomy_terms_on_taxonomy_term_id", using: :btree

  create_table "trait_descriptors", force: :cascade do |t|
    t.text     "descriptor_label"
    t.text     "category"
    t.text     "descriptor_name"
    t.text     "units_of_measurements"
    t.text     "where_to_score"
    t.text     "scoring_method"
    t.text     "when_to_score"
    t.text     "stage_scored"
    t.text     "precautions"
    t.text     "materials"
    t.text     "controls"
    t.text     "calibrated_against"
    t.text     "instrumentation_required"
    t.text     "likely_ambiguities"
    t.text     "contact_person"
    t.date     "date_method_agreed"
    t.text     "score_type"
    t.text     "related_trait_ids"
    t.text     "related_characters"
    t.text     "possible_interactions"
    t.text     "authorities"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "trait_scores_count",       default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",                default: true, null: false
    t.datetime "published_on"
    t.integer  "trait_id",                                null: false
    t.integer  "plant_part_id"
  end

  add_index "trait_descriptors", ["category"], name: "idx_144197_category", using: :btree
  add_index "trait_descriptors", ["descriptor_label"], name: "trait_descriptors_descriptor_label_idx", using: :btree
  add_index "trait_descriptors", ["descriptor_name"], name: "idx_144197_descriptor_name", using: :btree
  add_index "trait_descriptors", ["plant_part_id"], name: "index_trait_descriptors_on_plant_part_id", using: :btree
  add_index "trait_descriptors", ["published"], name: "index_trait_descriptors_on_published", using: :btree
  add_index "trait_descriptors", ["trait_id"], name: "index_trait_descriptors_on_trait_id", using: :btree
  add_index "trait_descriptors", ["user_id"], name: "index_trait_descriptors_on_user_id", using: :btree

  create_table "trait_grades", force: :cascade do |t|
    t.text     "trait_grade",         null: false
    t.text     "description"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.integer  "trait_descriptor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trait_grades", ["trait_descriptor_id"], name: "trait_grades_trait_descriptor_id_idx", using: :btree

  create_table "trait_scores", force: :cascade do |t|
    t.text     "score_value"
    t.text     "value_type"
    t.text     "comments"
    t.text     "entered_by_whom"
    t.date     "date_entered"
    t.text     "data_provenance"
    t.text     "data_owned_by"
    t.text     "confirmed_by_whom"
    t.integer  "plant_scoring_unit_id"
    t.integer  "trait_descriptor_id"
    t.date     "scoring_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "published",                  default: true, null: false
    t.datetime "published_on"
    t.integer  "technical_replicate_number", default: 1,    null: false
  end

  add_index "trait_scores", ["plant_scoring_unit_id"], name: "trait_scores_plant_scoring_unit_id_idx", using: :btree
  add_index "trait_scores", ["published"], name: "index_trait_scores_on_published", using: :btree
  add_index "trait_scores", ["trait_descriptor_id"], name: "trait_scores_trait_descriptor_id_idx", using: :btree
  add_index "trait_scores", ["user_id"], name: "index_trait_scores_on_user_id", using: :btree

  create_table "traits", force: :cascade do |t|
    t.string   "label",                          null: false
    t.string   "name",                           null: false
    t.string   "description"
    t.boolean  "canonical",       default: true, null: false
    t.string   "data_provenance"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "traits", ["label"], name: "index_traits_on_label", using: :btree
  add_index "traits", ["name"], name: "index_traits_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                          null: false
    t.string   "email"
    t.string   "full_name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "sign_in_count",      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  add_foreign_key "api_keys", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "genotype_matrices", "linkage_maps", on_update: :cascade, on_delete: :nullify
  add_foreign_key "linkage_groups", "linkage_maps", on_update: :cascade, on_delete: :nullify
  add_foreign_key "linkage_groups", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "linkage_maps", "plant_populations", on_update: :cascade, on_delete: :nullify
  add_foreign_key "linkage_maps", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_locus_hits", "linkage_groups", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_locus_hits", "linkage_maps", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_locus_hits", "map_positions", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_locus_hits", "population_loci", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_locus_hits", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_positions", "linkage_groups", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_positions", "marker_assays", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_positions", "population_loci", on_update: :cascade, on_delete: :nullify
  add_foreign_key "map_positions", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "marker_assays", "marker_sequence_assignments", on_update: :cascade, on_delete: :nullify
  add_foreign_key "marker_assays", "primers", column: "primer_a_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "marker_assays", "primers", column: "primer_b_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "marker_assays", "probes", on_update: :cascade, on_delete: :nullify
  add_foreign_key "marker_assays", "restriction_enzymes", column: "restriction_enzyme_a_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "marker_assays", "restriction_enzymes", column: "restriction_enzyme_b_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "marker_assays", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_accessions", "plant_lines", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_accessions", "plant_varieties", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_accessions", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_lines", "plant_varieties", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_lines", "taxonomy_terms", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_lines", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_population_lists", "plant_lines", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_population_lists", "plant_populations", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_population_lists", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_populations", "plant_lines", column: "female_parent_line_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_populations", "plant_lines", column: "male_parent_line_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_populations", "pop_type_lookup", column: "population_type_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_populations", "taxonomy_terms", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_populations", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_scoring_units", "design_factors", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_scoring_units", "plant_accessions", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_scoring_units", "plant_trials", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_scoring_units", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_trials", "countries", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_trials", "plant_populations", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_trials", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_varieties", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_variety_country_of_origin", "countries", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_variety_country_of_origin", "plant_varieties", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_variety_country_registered", "countries", on_update: :cascade, on_delete: :nullify
  add_foreign_key "plant_variety_country_registered", "plant_varieties", on_update: :cascade, on_delete: :nullify
  add_foreign_key "population_loci", "marker_assays", on_update: :cascade, on_delete: :nullify
  add_foreign_key "population_loci", "plant_populations", on_update: :cascade, on_delete: :nullify
  add_foreign_key "population_loci", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "primers", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "probes", "taxonomy_terms", on_update: :cascade, on_delete: :nullify
  add_foreign_key "probes", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "processed_trait_datasets", "plant_trials", on_update: :cascade, on_delete: :nullify
  add_foreign_key "processed_trait_datasets", "trait_descriptors", on_update: :cascade, on_delete: :nullify
  add_foreign_key "qtl", "linkage_groups", on_update: :cascade, on_delete: :nullify
  add_foreign_key "qtl", "processed_trait_datasets", on_update: :cascade, on_delete: :nullify
  add_foreign_key "qtl", "qtl_jobs", on_update: :cascade, on_delete: :nullify
  add_foreign_key "qtl", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "qtl_jobs", "linkage_maps", on_update: :cascade, on_delete: :nullify
  add_foreign_key "qtl_jobs", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "submission_uploads", "submissions", on_update: :cascade, on_delete: :restrict
  add_foreign_key "trait_descriptors", "plant_parts", on_update: :cascade, on_delete: :nullify
  add_foreign_key "trait_descriptors", "traits", on_update: :cascade, on_delete: :nullify
  add_foreign_key "trait_descriptors", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "trait_grades", "trait_descriptors", on_update: :cascade, on_delete: :nullify
  add_foreign_key "trait_scores", "plant_scoring_units", on_update: :cascade, on_delete: :nullify
  add_foreign_key "trait_scores", "trait_descriptors", on_update: :cascade, on_delete: :nullify
  add_foreign_key "trait_scores", "users", on_update: :cascade, on_delete: :nullify
end
