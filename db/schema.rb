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

ActiveRecord::Schema.define(version: 20150328144811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "countries", primary_key: "country_code", force: :cascade do |t|
    t.text "country_name",    default: "unspecified", null: false
    t.text "data_provenance",                         null: false
    t.text "comments",                                null: false
  end

  create_table "design_factors", primary_key: "design_factor_id", force: :cascade do |t|
    t.text "institute_id",        default: "unspecified", null: false
    t.text "trial_location_name", default: "unspecified", null: false
    t.text "design_unit_counter", default: "unspecified", null: false
    t.text "design_factor_1",     default: "unspecified", null: false
    t.text "design_factor_2",     default: "unspecified", null: false
    t.text "design_factor_3",     default: "unspecified", null: false
    t.text "design_factor_4",     default: "unspecified", null: false
    t.text "design_factor_5",     default: "unspecified", null: false
    t.text "comments",                                    null: false
    t.text "entered_by_whom",     default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                             null: false
    t.text "data_owned_by",       default: "unspecified", null: false
    t.text "confirmed_by_whom",   default: "unspecified"
  end

  add_index "design_factors", ["institute_id"], name: "idx_143500_institute_id", using: :btree

  create_table "genotype_matrices", primary_key: "linkage_map_id", force: :cascade do |t|
    t.text "martix_complied_by",       default: "unspecified", null: false
    t.text "original_file_name",       default: "unspecified", null: false
    t.date "date_matrix_available"
    t.text "number_markers_in_matrix", default: "unspecified", null: false
    t.text "number_lines_in_matrix",   default: "unspecified", null: false
    t.text "matrix",                                           null: false
    t.text "comments",                                         null: false
    t.text "entered_by_whom",          default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                  null: false
    t.text "data_owned_by",            default: "unspecified", null: false
  end

  create_table "linkage_groups", primary_key: "linkage_group_id", force: :cascade do |t|
    t.text "linkage_group_name",          default: "unspecified", null: false
    t.text "total_length",                default: "unspecified"
    t.text "lod_threshold",               default: "unspecified"
    t.text "consensus_group_assignment",  default: "unspecified", null: false
    t.text "consensus_group_orientation", default: "unspecified"
    t.text "comments",                                            null: false
    t.text "entered_by_whom",             default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                     null: false
    t.text "data_owned_by",               default: "unspecified", null: false
    t.text "data_status",                 default: "unspecified", null: false
    t.text "confirmed_by_whom",           default: "unspecified"
  end

  add_index "linkage_groups", ["linkage_group_name"], name: "idx_143534_linkage_group_name", using: :btree

  create_table "linkage_maps", primary_key: "linkage_map_id", force: :cascade do |t|
    t.text   "linkage_map_name",             default: "unspecified", null: false
    t.text   "mapping_population",           default: "unspecified", null: false
    t.string "map_version_no",     limit: 3, default: "xxx",         null: false
    t.date   "map_version_date"
    t.text   "mapping_software",             default: "unspecified"
    t.text   "mapping_function",             default: "unspecified"
    t.text   "map_author",                   default: "unspecified"
    t.text   "comments",                                             null: false
    t.text   "entered_by_whom",              default: "unspecified", null: false
    t.date   "date_entered"
    t.text   "data_provenance",                                      null: false
    t.text   "data_owned_by",                default: "unspecified", null: false
    t.text   "confirmed_by_whom",            default: "unspecified"
  end

  add_index "linkage_maps", ["mapping_population"], name: "idx_143550_mapping_population", using: :btree

  create_table "map_linkage_group_lists", primary_key: "linkage_map_id", force: :cascade do |t|
    t.text "linkage_group_id", default: "unspecified", null: false
    t.text "comments",                                 null: false
  end

  add_index "map_linkage_group_lists", ["linkage_group_id"], name: "idx_143567_linkage_group_id", using: :btree

  create_table "map_locus_hits", primary_key: "linkage_group_id", force: :cascade do |t|
    t.text "linkage_map_id",             default: "unspecified", null: false
    t.text "consensus_group_assignment", default: "unspecified", null: false
    t.text "mapping_locus",              default: "",            null: false
    t.text "canonical_marker_name",      default: "unspecified", null: false
    t.text "map_position",               default: "unspecified", null: false
    t.text "map_data_status",            default: "unspecified", null: false
    t.text "associated_sequence_id",     default: "unspecified", null: false
    t.text "sequence_source_acronym",    default: "unspecified", null: false
    t.text "cs_sequence_data_status",    default: "unspecified", null: false
    t.text "sqs_sequence_data_status",   default: "unspecified", null: false
    t.text "atg_hit_seq_id",             default: "unspecified", null: false
    t.text "atg_hit_seq_source",         default: "unspecified", null: false
    t.text "bac_hit_seq_id",             default: "unspecified", null: false
    t.text "bac_hit_seq_source",         default: "unspecified", null: false
    t.text "bac_hit_name",               default: "unspecified", null: false
  end

  create_table "map_positions", primary_key: "linkage_group_id", force: :cascade do |t|
    t.text "marker_assay_name", default: "unspecified", null: false
    t.text "mapping_locus",     default: "unspecified", null: false
    t.text "map_position",      default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  add_index "map_positions", ["map_position"], name: "idx_143597_map_position", using: :btree
  add_index "map_positions", ["mapping_locus"], name: "idx_143597_mapping_locus", using: :btree

  create_table "marker_assays", primary_key: "marker_assay_name", force: :cascade do |t|
    t.text "canonical_marker_name", default: "unspecified", null: false
    t.text "marker_type",           default: "unspecified"
    t.text "probe_name",            default: "unspecified"
    t.text "primer_a",              default: "unspecified"
    t.text "primer_b",              default: "unspecified"
    t.text "separation_system",     default: "unspecified"
    t.text "comments",                                      null: false
    t.text "entered_by_whom",       default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance"
    t.text "data_owned_by",         default: "unspecified", null: false
    t.text "confirmed_by_whom",     default: "unspecified"
  end

  create_table "marker_sequence_assignments", primary_key: "canonical_marker_name", force: :cascade do |t|
    t.text "marker_set",              default: "unspecified", null: false
    t.text "associated_sequence_id",  default: "unspecified"
    t.text "sequence_source_acronym", default: "unspecified"
    t.text "comments"
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance"
    t.text "data_owned_by",           default: "unspecified"
  end

  add_index "marker_sequence_assignments", ["canonical_marker_name"], name: "idx_143632_canonical_marker_name", using: :btree

  create_table "occasions", primary_key: "occasion_id", force: :cascade do |t|
    t.date "start_date"
    t.text "start_time",        default: "unspecified"
    t.date "end_date"
    t.text "end_time",          default: "unspecified"
    t.text "scored_by_whom",    default: "unspecified"
    t.text "recorded_by_whom",  default: "unspecified"
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified"
  end

  create_table "plant_accessions", primary_key: "plant_accession", force: :cascade do |t|
    t.text "plant_line_name",            default: "unspecified", null: false
    t.text "plant_accession_derivation", default: "unspecified"
    t.text "accession_originator",       default: "unspecified"
    t.text "originating_organisation",   default: "unspecified"
    t.text "year_produced",              default: "xxxx",        null: false
    t.date "date_harvested"
    t.text "female_parent_plant_id",     default: "unspecified"
    t.text "male_parent_plant_id",       default: "unspecified"
    t.text "comments",                                           null: false
    t.text "entered_by_whom",            default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                    null: false
    t.text "data_owned_by",              default: "unspecified", null: false
    t.text "confirmed_by_whom",          default: "unspecified"
  end

  add_index "plant_accessions", ["plant_line_name"], name: "idx_143691_plant_line", using: :btree

  create_table "plant_lines", primary_key: "plant_line_name", force: :cascade do |t|
    t.text    "genus",              default: "unspecified", null: false
    t.text    "species",            default: "unspecified"
    t.text    "subtaxa",            default: "unspecified"
    t.text    "common_name",        default: "unspecified"
    t.text    "plant_variety_name", default: "unspecified"
    t.text    "named_by_whom",      default: "unspecified"
    t.text    "organisation",       default: "unspecified"
    t.text    "genetic_status",     default: "unspecified"
    t.text    "previous_line_name", default: "unspecified"
    t.text    "comments",                                   null: false
    t.text    "entered_by_whom",    default: "unspecified", null: false
    t.date    "date_entered"
    t.text    "data_provenance"
    t.text    "data_owned_by",      default: "unspecified"
    t.text    "confirmed_by_whom",  default: "unspecified"
    t.integer "taxonomy_term_id"
  end

  add_index "plant_lines", ["plant_variety_name"], name: "idx_143729_plant_variety", using: :btree
  add_index "plant_lines", ["taxonomy_term_id"], name: "index_plant_lines_on_taxonomy_term_id", using: :btree

  create_table "plant_parts", primary_key: "plant_part", force: :cascade do |t|
    t.text "description",                               null: false
    t.text "described_by_whom", default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  create_table "plant_population_lists", primary_key: "plant_population_id", force: :cascade do |t|
    t.text "plant_line_name",   default: "unspecified", null: false
    t.text "sort_order",        default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance"
    t.text "confirmed_by_whom", default: "unspecified"
  end

  add_index "plant_population_lists", ["plant_line_name"], name: "idx_143830_plant_line", using: :btree

  create_table "plant_populations", primary_key: "plant_population_id", force: :cascade do |t|
    t.text "population_type",           default: "unspecified"
    t.text "female_parent_line",        default: "unspecified"
    t.text "male_parent_line",          default: "unspecified"
    t.text "canonical_population_name", default: "unspecified"
    t.text "description"
    t.date "date_established"
    t.text "established_by_whom",       default: "unspecified"
    t.text "establishing_organisation", default: "unspecified"
    t.text "population_owned_by",       default: "unspecified"
    t.text "comments"
    t.text "entered_by_whom",           default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_owned_by",             default: "unspecified"
    t.text "data_provenance"
    t.text "confirmed_by_whom",         default: "unspecified"
    t.text "plant_population_name",     default: "unspecified", null: false
    t.text "assigned_population_name",  default: "unspecified", null: false
  end

  create_table "plant_scoring_units", primary_key: "scoring_unit_id", force: :cascade do |t|
    t.text "plant_trial_id",           default: "unspecified", null: false
    t.text "design_factor_id",         default: "unspecified", null: false
    t.text "plant_accession",          default: "unspecified", null: false
    t.text "scored_plant_part",        default: "unspecified", null: false
    t.text "number_units_scored",      default: "unspecified"
    t.text "scoring_unit_sample_size", default: "unspecified"
    t.text "scoring_unit_frame_size",  default: "unspecified"
    t.date "date_planted"
    t.text "described_by_whom",        default: "unspecified"
    t.text "comments",                                         null: false
    t.text "entered_by_whom",          default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                  null: false
    t.text "data_owned_by",            default: "unspecified", null: false
    t.text "confirmed_by_whom",        default: "unspecified"
  end

  add_index "plant_scoring_units", ["plant_accession"], name: "idx_143842_trial", using: :btree
  add_index "plant_scoring_units", ["scored_plant_part"], name: "idx_143842_row_plot_position", using: :btree

  create_table "plant_trials", primary_key: "plant_trial_id", force: :cascade do |t|
    t.text   "project_descriptor",                 default: "unspecified", null: false
    t.text   "plant_trial_description",                                    null: false
    t.text   "plant_population",                   default: "unspecified", null: false
    t.text   "trial_year",                         default: "xxxx",        null: false
    t.text   "institute_id",                       default: "unspecified", null: false
    t.text   "trial_location_site_name",           default: "unspecified", null: false
    t.string "country",                  limit: 3, default: "xxx",         null: false
    t.text   "place_name",                         default: "unspecified", null: false
    t.text   "latitude",                           default: "unspecified", null: false
    t.text   "longitude",                          default: "unspecified", null: false
    t.text   "altitude",                           default: "unspecified"
    t.text   "terrain",                            default: "unspecified"
    t.text   "soil_type",                          default: "unspecified"
    t.text   "contact_person",                     default: "unspecified", null: false
    t.text   "design_type",                        default: "unspecified"
    t.text   "statistical_factors"
    t.text   "design_factors"
    t.text   "design_layout_matrix"
    t.text   "comments",                                                   null: false
    t.text   "entered_by_whom",                    default: "unspecified", null: false
    t.date   "date_entered"
    t.text   "data_provenance",                                            null: false
    t.text   "data_owned_by",                      default: "unspecified", null: false
    t.text   "confirmed_by_whom",                  default: "unspecified"
  end

  create_table "plant_varieties", force: :cascade do |t|
    t.string "plant_variety_name"
    t.string "crop_type"
    t.string "comments"
    t.text   "entered_by_whom",       default: "unspecified", null: false
    t.date   "date_entered"
    t.string "data_provenance"
    t.string "data_attribution",      default: "unspecified", null: false
    t.string "country_of_origin",     default: "xxx",         null: false
    t.string "country_registered",    default: "xxx",         null: false
    t.string "year_registered",       default: "xxxx",        null: false
    t.string "breeders_variety_code"
    t.string "owner"
    t.string "quoted_parentage"
    t.string "female_parent"
    t.string "male_parent"
  end

  create_table "pop_type_lookup", primary_key: "population_type", force: :cascade do |t|
    t.text "population_class", default: "unspecified", null: false
    t.text "assigned_by_whom", default: "unspecified", null: false
  end

  create_table "population_loci", primary_key: "mapping_locus", force: :cascade do |t|
    t.text "plant_population",  default: "unspecified", null: false
    t.text "marker_assay_name", default: "unspecified", null: false
    t.text "defined_by_whom",   default: "unspecified"
    t.text "comments"
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
  end

  add_index "population_loci", ["mapping_locus"], name: "idx_143961_mapping_locus", using: :btree
  add_index "population_loci", ["marker_assay_name"], name: "idx_143961_marker_assay", using: :btree
  add_index "population_loci", ["plant_population"], name: "idx_143961_plant_population", using: :btree

  create_table "primers", primary_key: "primer", force: :cascade do |t|
    t.text "sequence",                default: "unspecified", null: false
    t.text "sequence_id",             default: "unspecified", null: false
    t.text "sequence_source_acronym", default: "unspecified", null: false
    t.text "description"
    t.text "comments",                                        null: false
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                 null: false
    t.text "data_owned_by",           default: "unspecified"
  end

  create_table "probes", primary_key: "probe_name", force: :cascade do |t|
    t.text "species",                 default: "unspecified", null: false
    t.text "clone_name",              default: "unspecified", null: false
    t.date "date_described"
    t.text "sequence_id",             default: "unspecified", null: false
    t.text "sequence_source_acronym", default: "unspecified", null: false
    t.text "comments",                                        null: false
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                 null: false
  end

  create_table "processed_trait_datasets", primary_key: "processed_trait_dataset_id", force: :cascade do |t|
    t.text "trial_id",                   default: "unspecified", null: false
    t.text "trait_descriptor_id",        default: "unspecified", null: false
    t.text "population_id",              default: "unspecified", null: false
    t.text "processed_dataset_id",       default: "unspecified"
    t.text "trait_percent_heritability", default: "unspecified"
    t.text "comments",                                           null: false
    t.text "entered_by_whom",            default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                    null: false
    t.text "data_owned_by",              default: "unspecified", null: false
  end

  add_index "processed_trait_datasets", ["trial_id", "trait_descriptor_id", "population_id"], name: "idx_144089_trial_id", using: :btree

  create_table "qtl", primary_key: "qtl_job_id", force: :cascade do |t|
    t.text "processed_trait_dataset_id", default: "unspecified", null: false
    t.text "linkage_group_id",           default: "unspecified", null: false
    t.text "qtl_rank",                   default: "unspecified", null: false
    t.text "map_qtl_label",              default: "unspecified", null: false
    t.text "outer_interval_start",       default: "unspecified"
    t.text "inner_interval_start",       default: "unspecified"
    t.text "qtl_mid_position",           default: "unspecified", null: false
    t.text "inner_interval_end",         default: "unspecified"
    t.text "outer_interval_end",         default: "unspecified"
    t.text "peak_value",                 default: "unspecified"
    t.text "peak_p_value",               default: "unspecified"
    t.text "regression_p",               default: "unspecified"
    t.text "residual_p",                 default: "unspecified"
    t.text "additive_effect",            default: "unspecified", null: false
    t.text "genetic_variance_explained", default: "unspecified"
    t.text "comments",                                           null: false
    t.text "entered_by_whom",            default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                    null: false
    t.text "data_owned_by",              default: "unspecified", null: false
  end

  add_index "qtl", ["linkage_group_id"], name: "idx_144113_linkage_group", using: :btree
  add_index "qtl", ["processed_trait_dataset_id"], name: "idx_144113_trial", using: :btree

  create_table "qtl_jobs", primary_key: "qtl_job_id", force: :cascade do |t|
    t.text "linkage_map_id",                 default: "unspecified", null: false
    t.text "qtl_software",                   default: "unspecified", null: false
    t.text "qtl_method",                     default: "unspecified", null: false
    t.text "threshold_specification_method"
    t.text "interval_type",                  default: "unspecified"
    t.text "inner_confidence_threshold",     default: "unspecified"
    t.text "outer_confidence_threshold",     default: "unspecified"
    t.text "qtl_statistic_type",             default: "unspecified"
    t.text "described_by_whom",              default: "unspecified"
    t.date "date_run"
    t.text "comments",                                               null: false
    t.text "entered_by_whom",                default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                        null: false
    t.text "data_owned_by",                  default: "unspecified", null: false
  end

  add_index "qtl_jobs", ["linkage_map_id"], name: "idx_144140_linkage_map_id", using: :btree
  add_index "qtl_jobs", ["qtl_software", "qtl_method"], name: "idx_144140_qtl_software", using: :btree

  create_table "restriction_enzymes", primary_key: "restriction_enzyme", force: :cascade do |t|
    t.text "recognition_site", default: "unspecified", null: false
    t.text "data_provenance",                          null: false
  end

  create_table "scoring_occasions", primary_key: "scoring_occasion_id", force: :cascade do |t|
    t.date "score_start_date"
    t.date "score_end_date"
    t.text "comments",                                 null: false
    t.text "entered_by_whom",  default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                          null: false
    t.text "data_owned_by",    default: "unspecified", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id",                    null: false
    t.string   "step",                       null: false
    t.json     "content",    default: {},    null: false
    t.boolean  "finalized",  default: false, null: false
  end

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

  create_table "trait_descriptors", primary_key: "trait_descriptor_id", force: :cascade do |t|
    t.text "category",                 default: "unspecified", null: false
    t.text "descriptor_name",          default: "unspecified", null: false
    t.text "units_of_measurements",    default: "unspecified"
    t.text "where_to_score",                                   null: false
    t.text "scoring_method"
    t.text "when_to_score",            default: "unspecified"
    t.text "stage_scored",             default: "unspecified"
    t.text "precautions"
    t.text "materials"
    t.text "controls"
    t.text "calibrated_against"
    t.text "instrumentation_required"
    t.text "likely_ambiguities"
    t.text "contact_person",           default: "unspecified"
    t.date "date_method_agreed"
    t.text "score_type",               default: "unspecified"
    t.text "related_trait_ids"
    t.text "related_characters"
    t.text "possible_interactions"
    t.text "authorities",              default: "unspecified"
    t.text "comments",                                         null: false
    t.text "entered_by_whom",          default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                  null: false
    t.text "data_owned_by",            default: "unspecified", null: false
    t.text "confirmed_by_whom",        default: "unspecified"
  end

  add_index "trait_descriptors", ["category"], name: "idx_144197_category", using: :btree
  add_index "trait_descriptors", ["descriptor_name"], name: "idx_144197_descriptor_name", using: :btree
  add_index "trait_descriptors", ["trait_descriptor_id"], name: "idx_144197_trait_descriptor_id", using: :btree

  create_table "trait_grades", primary_key: "trait_descriptor_id", force: :cascade do |t|
    t.text "trait_grade",     default: "unspecified", null: false
    t.text "description",                             null: false
    t.text "comments",                                null: false
    t.text "entered_by_whom", default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                         null: false
  end

  create_table "trait_scores", primary_key: "scoring_unit_id", force: :cascade do |t|
    t.text "scoring_occasion_id",     default: "unspecified", null: false
    t.text "trait_descriptor_id",     default: "unspecified", null: false
    t.text "replicate_score_reading", default: "unspecified", null: false
    t.text "score_value"
    t.text "score_spread",            default: "unspecified"
    t.text "value_type",              default: "unspecified"
    t.text "comments",                                        null: false
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                 null: false
    t.text "data_owned_by",           default: "unspecified", null: false
    t.text "confirmed_by_whom",       default: "unspecified"
  end

  add_index "trait_scores", ["scoring_occasion_id"], name: "idx_144229_scoring_occasion", using: :btree
  add_index "trait_scores", ["trait_descriptor_id"], name: "idx_144229_trait_descriptor", using: :btree

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

  create_table "version", primary_key: "version", force: :cascade do |t|
    t.date "date"
    t.text "updated_by_whom", default: "unspecified", null: false
    t.text "comments",                                null: false
  end

end
