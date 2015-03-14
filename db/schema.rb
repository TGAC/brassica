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

ActiveRecord::Schema.define(version: 20150225145528) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "clone_libraries", id: false, force: :cascade do |t|
    t.text "library_name"
    t.text "library_type",                default: "unspecified", null: false
    t.text "genus",                       default: "unspecified", null: false
    t.text "species",                     default: "unspecified", null: false
    t.text "subspecies",                  default: "unspecified", null: false
    t.text "plant_accession"
    t.text "tissue",                      default: "unspecified", null: false
    t.text "made_by_whom",                default: "unspecified", null: false
    t.text "where_made",                  default: "unspecified", null: false
    t.date "date_made"
    t.text "plant_growth_location",       default: "unspecified", null: false
    t.text "plant_growth_conditions",                             null: false
    t.text "plant_treatment_details",                             null: false
    t.text "plant_stage_sampled",         default: "unspecified", null: false
    t.text "plant_amount_sampled",        default: "unspecified", null: false
    t.date "date_sampled"
    t.text "plant_tissue_storage_method", default: "unspecified", null: false
    t.text "rna_preparation",             default: "unspecified", null: false
    t.text "dna_preparation",             default: "unspecified", null: false
    t.text "bacterial_strain",            default: "unspecified", null: false
    t.text "vector",                      default: "unspecified", null: false
    t.text "cloning_site",                default: "unspecified", null: false
    t.text "antibiotic_selection",        default: "unspecified", null: false
    t.text "number_of_clones",            default: "unspecified", null: false
    t.text "plate_format_picked_into",    default: "unspecified", null: false
    t.text "library_owned_by",            default: "unspecified", null: false
    t.text "library_status",              default: "unspecified", null: false
    t.text "entered_by_whom",             default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                     null: false
    t.text "data_owned_by",               default: "unspecified", null: false
    t.text "data_status",                 default: "unspecified", null: false
    t.text "confirmed_by_whom",           default: "unspecified", null: false
    t.text "comments",                                            null: false
  end

  add_index "clone_libraries", ["genus"], name: "idx_143333_genus", using: :btree
  add_index "clone_libraries", ["library_type"], name: "idx_143333_library_type", using: :btree
  add_index "clone_libraries", ["plant_accession"], name: "idx_143333_fk_clone_libraries_1", using: :btree
  add_index "clone_libraries", ["species"], name: "idx_143333_species", using: :btree

  create_table "clones", id: false, force: :cascade do |t|
    t.text "clone_name"
    t.text "library_name",            default: "unspecified", null: false
    t.text "clone_type",              default: "unspecified", null: false
    t.text "gene",                    default: "unspecified", null: false
    t.text "sequence_id",             default: "unspecified", null: false
    t.text "sequence_source_acronym", default: "unspecified", null: false
    t.text "description",                                     null: false
    t.text "donor_name",              default: "unspecified", null: false
    t.date "donor_date"
    t.text "insert_length_bp",        default: "unspecified", null: false
    t.text "curated_by_whom",         default: "unspecified", null: false
    t.text "curated_location",        default: "unspecified", null: false
    t.text "archived_location",       default: "unspecified", null: false
    t.text "comments",                                        null: false
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                 null: false
    t.text "data_owned_by",           default: "unspecified", null: false
    t.text "data_status",             default: "unspecified", null: false
    t.text "confirmed_by_whom",       default: "unspecified", null: false
  end

  add_index "clones", ["clone_type"], name: "idx_143312_clone_type", using: :btree
  add_index "clones", ["library_name"], name: "idx_143312_fk_clones_1", using: :btree

  create_table "countries", id: false, force: :cascade do |t|
    t.text "country_code"
    t.text "country_name",    default: "unspecified", null: false
    t.text "data_provenance",                         null: false
    t.text "comments",                                null: false
  end

  create_table "cs_additional_information", id: false, force: :cascade do |t|
    t.text "table_name"
    t.text "single_key_field",       default: "unspecified", null: false
    t.text "key_value",              default: "unspecified", null: false
    t.text "additional_count",       default: "unspecified", null: false
    t.text "additional_type",        default: "unspecified", null: false
    t.text "additional_information",                         null: false
    t.text "comments",                                       null: false
    t.text "entered_by_whom",        default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                null: false
    t.text "data_owned_by",          default: "unspecified", null: false
    t.text "data_status",            default: "unspecified", null: false
    t.text "confirmed_by_whom",      default: "unspecified", null: false
  end

  create_table "cs_images", primary_key: "cs_image_id", force: :cascade do |t|
    t.text "image_filename",        default: "unspecified", null: false
    t.text "image_filepath",                                null: false
    t.text "image_description",                             null: false
    t.text "image_created_by_whom", default: "unspecified", null: false
    t.text "copyright_status",      default: "unspecified", null: false
    t.text "image_owned_by_whom",   default: "unspecified", null: false
    t.text "comments",                                      null: false
    t.text "entered_by_whom",       default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                               null: false
    t.text "data_owned_by",         default: "unspecified", null: false
    t.text "data_status",           default: "unspecified", null: false
    t.text "confirmed_by_whom",     default: "unspecified", null: false
  end

  create_table "cs_images_lookup", primary_key: "cs_image_id", force: :cascade do |t|
    t.text     "cs_database",       default: "unspecified", null: false
    t.text     "cs_table",          default: "unspecified", null: false
    t.text     "cs_key_field",      default: "unspecified", null: false
    t.text     "cs_value",          default: "unspecified", null: false
    t.text     "assigned_by_whom",  default: "unspecified", null: false
    t.text     "comments",                                  null: false
    t.text     "entered_by_whom",   default: "unspecified", null: false
    t.datetime "date_entered"
    t.text     "confirmed_by_whom", default: "unspecified", null: false
  end

  create_table "cs_institutions", primary_key: "cs_institution_id", force: :cascade do |t|
    t.text   "institution_name",                  default: "unspecified", null: false
    t.text   "institution_address1",              default: "unspecified", null: false
    t.text   "institution_address2",              default: "unspecified", null: false
    t.text   "town",                              default: "unspecified", null: false
    t.text   "county_district",                   default: "unspecified", null: false
    t.text   "zip_postcode",                      default: "unspecified", null: false
    t.string "country_id",              limit: 3, default: "xxx",         null: false
    t.text   "website"
    t.text   "previous_institution_id",           default: "unspecified"
    t.text   "comments",                                                  null: false
    t.text   "entered_by_whom",                   default: "unspecified", null: false
    t.date   "date_entered"
    t.text   "confirmed_by_whom",                 default: "unspecified", null: false
  end

  create_table "cs_people", primary_key: "cs_person_id", force: :cascade do |t|
    t.text "first_name",              default: "unspecified", null: false
    t.text "first_initials",          default: "unspecified", null: false
    t.text "surname",                 default: "unspecified", null: false
    t.text "full_name",               default: "unspecified", null: false
    t.text "current_institution_id",  default: "unspecified", null: false
    t.text "department",              default: "unspecified", null: false
    t.text "role",                    default: "unspecified", null: false
    t.text "phone_number",            default: "unspecified", null: false
    t.text "fax_number",              default: "unspecified", null: false
    t.text "current_email",                                   null: false
    t.text "homepage",                                        null: false
    t.text "previous_institution_id", default: "unspecified", null: false
    t.text "previous_email",                                  null: false
    t.text "comments",                                        null: false
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "confirmed_by_whom",       default: "unspecified", null: false
  end

  create_table "cs_publications", primary_key: "cs_publication_id", force: :cascade do |t|
    t.text "first_author",        default: "unspecified", null: false
    t.text "remaining_authors",                           null: false
    t.text "coresponding_author", default: "unspecified", null: false
    t.text "year_published",      default: "xxxx",        null: false
    t.text "journal",             default: "unspecified", null: false
    t.text "paper_title",                                 null: false
    t.text "doi",                                         null: false
    t.text "pmid",                default: "unspecified", null: false
    t.text "url",                                         null: false
    t.text "reference_summary",                           null: false
    t.text "assigned_by_whom",    default: "unspecified", null: false
    t.text "comments",                                    null: false
    t.text "entered_by_whom",     default: "unspecified", null: false
    t.date "date_entered"
    t.text "confirmed_by_whom",   default: "unspecified", null: false
  end

  create_table "cs_publications_lookup", primary_key: "cs_publication_id", force: :cascade do |t|
    t.text     "cs_database",       default: "unspecified", null: false
    t.text     "cs_table",          default: "unspecified", null: false
    t.text     "cs_key_field",      default: "unspecified", null: false
    t.text     "cs_value",          default: "unspecified", null: false
    t.text     "assigned_by_whom",  default: "unspecified", null: false
    t.text     "comments",                                  null: false
    t.text     "entered_by_whom",   default: "unspecified", null: false
    t.datetime "date_entered"
    t.text     "confirmed_by_whom", default: "unspecified", null: false
  end

  create_table "cs_synonyms", primary_key: "cs_synonym_id", force: :cascade do |t|
    t.text "cs_database",       default: "unspecified", null: false
    t.text "cs_table",          default: "unspecified", null: false
    t.text "cs_key_field",      default: "unspecified", null: false
    t.text "cs_value",          default: "unspecified", null: false
    t.text "synonym_value",     default: "unspecified", null: false
    t.text "synonym_status",    default: "unspecified", null: false
    t.text "described_by_whom", default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
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
    t.text "data_status",         default: "unspecified", null: false
    t.text "confirmed_by_whom",   default: "unspecified", null: false
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
    t.text "data_status",              default: "unspecified", null: false
    t.text "confirmed_by_whom",        default: "unspecified", null: false
  end

  create_table "linkage_groups", primary_key: "linkage_group_id", force: :cascade do |t|
    t.text "linkage_group_name",          default: "unspecified", null: false
    t.text "total_length",                default: "unspecified", null: false
    t.text "lod_threshold",               default: "unspecified", null: false
    t.text "consensus_group_assignment",  default: "unspecified", null: false
    t.text "consensus_group_orientation", default: "unspecified", null: false
    t.text "comments",                                            null: false
    t.text "entered_by_whom",             default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                     null: false
    t.text "data_owned_by",               default: "unspecified", null: false
    t.text "data_status",                 default: "unspecified", null: false
    t.text "confirmed_by_whom",           default: "unspecified", null: false
  end

  add_index "linkage_groups", ["linkage_group_name"], name: "idx_143534_linkage_group_name", using: :btree

  create_table "linkage_maps", primary_key: "linkage_map_id", force: :cascade do |t|
    t.text   "linkage_map_name",             default: "unspecified", null: false
    t.text   "mapping_population",           default: "unspecified", null: false
    t.string "map_version_no",     limit: 3, default: "xxx",         null: false
    t.date   "map_version_date"
    t.text   "mapping_software",             default: "unspecified", null: false
    t.text   "mapping_function",             default: "unspecified", null: false
    t.text   "map_author",                   default: "unspecified", null: false
    t.text   "comments",                                             null: false
    t.text   "entered_by_whom",              default: "unspecified", null: false
    t.date   "date_entered"
    t.text   "data_provenance",                                      null: false
    t.text   "data_owned_by",                default: "unspecified", null: false
    t.text   "data_status",                  default: "unspecified", null: false
    t.text   "confirmed_by_whom",            default: "unspecified", null: false
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
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  add_index "map_positions", ["map_position"], name: "idx_143597_map_position", using: :btree
  add_index "map_positions", ["mapping_locus"], name: "idx_143597_mapping_locus", using: :btree

  create_table "marker_assays", id: false, force: :cascade do |t|
    t.text "marker_assay_name"
    t.text "canonical_marker_name",      default: "unspecified", null: false
    t.text "marker_type",                default: "unspecified", null: false
    t.text "probe_name",                 default: "unspecified", null: false
    t.text "primer_a",                   default: "unspecified", null: false
    t.text "primer_b",                   default: "unspecified", null: false
    t.text "restriction_enzyme_a",       default: "unspecified", null: false
    t.text "restriction_enzyme_b",       default: "unspecified", null: false
    t.text "reanneal_temp",              default: "unspecified", null: false
    t.text "separation_system",          default: "unspecified", null: false
    t.text "sequence_confirmed_by_whom", default: "unspecified", null: false
    t.text "comments",                                           null: false
    t.text "entered_by_whom",            default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                    null: false
    t.text "data_owned_by",              default: "unspecified", null: false
    t.text "data_status",                default: "unspecified", null: false
    t.text "confirmed_by_whom",          default: "unspecified", null: false
  end

  create_table "marker_sequence_assignments", id: false, force: :cascade do |t|
    t.text "canonical_marker_name"
    t.text "marker_set",              default: "unspecified", null: false
    t.text "associated_sequence_id",  default: "unspecified", null: false
    t.text "sequence_source_acronym", default: "unspecified", null: false
    t.text "described_by_whom",       default: "unspecified", null: false
    t.text "comments",                                        null: false
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                 null: false
    t.text "data_owned_by",           default: "unspecified", null: false
    t.text "data_status",             default: "unspecified", null: false
    t.text "confirmed_by_whom",       default: "unspecified", null: false
  end

  add_index "marker_sequence_assignments", ["canonical_marker_name"], name: "idx_143632_canonical_marker_name", using: :btree

  create_table "marker_sequence_hits", id: false, force: :cascade do |t|
    t.text "canonical_marker_name"
    t.text "target_collection_id",        default: "unspecified", null: false
    t.text "hit_rank_number",             default: "unspecified", null: false
    t.text "target_hit_id",               default: "unspecified", null: false
    t.text "analysis_caried_out_by_whom", default: "unspecified", null: false
    t.text "comments",                                            null: false
    t.text "entered_by_whom",             default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                     null: false
    t.text "data_owned_by",               default: "unspecified", null: false
    t.text "marker_data_status",          default: "unspecified", null: false
    t.text "target_collection_status",    default: "unspecified", null: false
    t.text "confirmed_by_whom",           default: "unspecified", null: false
  end

  create_table "marker_variations", id: false, force: :cascade do |t|
    t.text "marker_variation"
    t.text "marker_assay_name", default: "unspecified", null: false
    t.text "description",                               null: false
    t.text "described_by_whom", default: "unspecified", null: false
    t.date "date_described"
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  add_index "marker_variations", ["marker_assay_name"], name: "idx_143663_marker_assay", using: :btree

  create_table "occasions", primary_key: "occasion_id", force: :cascade do |t|
    t.date "start_date"
    t.text "start_time",        default: "unspecified", null: false
    t.date "end_date"
    t.text "end_time",          default: "unspecified", null: false
    t.text "scored_by_whom",    default: "unspecified", null: false
    t.text "recorded_by_whom",  default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  create_table "plant_accessions", id: false, force: :cascade do |t|
    t.text "plant_accession"
    t.text "plant_line_name",            default: "unspecified", null: false
    t.text "plant_accession_derivation", default: "unspecified", null: false
    t.text "accession_originator",       default: "unspecified", null: false
    t.text "originating_organisation",   default: "unspecified", null: false
    t.text "ownership",                  default: "unspecified", null: false
    t.text "year_produced",              default: "xxxx",        null: false
    t.text "pollination_method",         default: "unspecified", null: false
    t.date "date_harvested"
    t.text "female_parent_plant_id",     default: "unspecified", null: false
    t.text "male_parent_plant_id",       default: "unspecified", null: false
    t.text "comments",                                           null: false
    t.text "entered_by_whom",            default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                    null: false
    t.text "data_owned_by",              default: "unspecified", null: false
    t.text "data_status",                default: "unspecified", null: false
    t.text "confirmed_by_whom",          default: "unspecified", null: false
  end

  add_index "plant_accessions", ["plant_line_name"], name: "idx_143691_plant_line", using: :btree

  create_table "plant_individuals", primary_key: "plant_individual_id", force: :cascade do |t|
    t.text "plant_accession",      default: "unspecified", null: false
    t.text "seed_packet_id",       default: "unspecified", null: false
    t.text "plant_trial_id",       default: "unspecified", null: false
    t.text "row_plot_position_id", default: "unspecified", null: false
    t.text "plant_sample_size",    default: "unspecified", null: false
    t.text "plant_number",         default: "unspecified", null: false
    t.date "date_planted"
    t.text "described_by_whom",    default: "unspecified", null: false
    t.text "comments",                                     null: false
    t.text "entered_by_whom",      default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                              null: false
    t.text "data_owned_by",        default: "unspecified", null: false
    t.text "data_status",          default: "unspecified", null: false
    t.text "confirmed_by_whom",    default: "unspecified", null: false
  end

  add_index "plant_individuals", ["plant_accession"], name: "idx_143711_plant_accession", using: :btree
  add_index "plant_individuals", ["plant_individual_id"], name: "idx_143711_individual", using: :btree
  add_index "plant_individuals", ["plant_trial_id"], name: "idx_143711_trial", using: :btree
  add_index "plant_individuals", ["row_plot_position_id"], name: "idx_143711_row_plot_position", using: :btree

  create_table "plant_line_assigned_genotypes", id: false, force: :cascade do |t|
    t.text "plant_line_name"
    t.text "plant_population",      default: "unspecified", null: false
    t.text "mapping_locus",         default: "unspecified", null: false
    t.text "zygote_locus_genotype", default: "unspecified", null: false
    t.text "assigned_by_whom",      default: "unspecified", null: false
    t.date "date_assigned"
    t.text "comments",                                      null: false
    t.text "entered_by_whom",       default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                               null: false
    t.text "data_owned_by",         default: "unspecified", null: false
    t.text "data_status",           default: "unspecified", null: false
    t.text "confirmed_by_whom",     default: "unspecified", null: false
  end

  add_index "plant_line_assigned_genotypes", ["mapping_locus"], name: "idx_143749_mapping_locus", using: :btree
  add_index "plant_line_assigned_genotypes", ["plant_line_name"], name: "idx_143749_plant_line", using: :btree
  add_index "plant_line_assigned_genotypes", ["plant_population", "mapping_locus", "zygote_locus_genotype"], name: "idx_143749_fk_plant_line_assigned_genotypes_1", using: :btree

  create_table "plant_lines", id: false, force: :cascade do |t|
    t.text    "plant_line_name"
    t.text    "genus",              default: "unspecified", null: false
    t.text    "species",            default: "unspecified", null: false
    t.text    "subtaxa",            default: "unspecified", null: false
    t.text    "common_name",        default: "unspecified", null: false
    t.text    "plant_variety_name", default: "unspecified", null: false
    t.text    "named_by_whom",      default: "unspecified", null: false
    t.text    "organisation",       default: "unspecified", null: false
    t.text    "genetic_status",     default: "unspecified", null: false
    t.text    "previous_line_name", default: "unspecified", null: false
    t.text    "comments",                                   null: false
    t.text    "entered_by_whom",    default: "unspecified", null: false
    t.date    "date_entered"
    t.text    "data_provenance",                            null: false
    t.text    "data_owned_by",      default: "unspecified", null: false
    t.text    "data_status",        default: "unspecified", null: false
    t.text    "confirmed_by_whom",  default: "unspecified", null: false
    t.integer "taxonomy_term_id"
  end

  add_index "plant_lines", ["plant_variety_name"], name: "idx_143729_plant_variety", using: :btree
  add_index "plant_lines", ["taxonomy_term_id"], name: "index_plant_lines_on_taxonomy_term_id", using: :btree

  create_table "plant_marker_fragments", primary_key: "scoring_unit_id", force: :cascade do |t|
    t.text "marker_variation",       default: "unspecified", null: false
    t.text "occasion",               default: "unspecified", null: false
    t.text "fragment_number",        default: "unspecified", null: false
    t.text "total_number_fragments", default: "unspecified", null: false
    t.text "calculated_value",       default: "unspecified", null: false
    t.text "units",                  default: "unspecified", null: false
    t.text "comments",                                       null: false
    t.text "entered_by_whom",        default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                null: false
    t.text "data_owned_by",          default: "unspecified", null: false
    t.text "data_status",            default: "unspecified", null: false
    t.text "confirmed_by_whom",      default: "unspecified", null: false
  end

  add_index "plant_marker_fragments", ["fragment_number"], name: "idx_143764_fragment_number", using: :btree
  add_index "plant_marker_fragments", ["marker_variation"], name: "idx_143764_marker_variation", using: :btree
  add_index "plant_marker_fragments", ["occasion"], name: "idx_143764_occasion", using: :btree

  create_table "plant_marker_variations", primary_key: "scoring_unit_id", force: :cascade do |t|
    t.text   "marker_variation",            default: "unspecified", null: false
    t.text   "occasion",                    default: "unspecified", null: false
    t.text   "scored_by_whom",              default: "unspecified", null: false
    t.text   "lab_notebook_code",           default: "unspecified", null: false
    t.string "lab_notebook_page", limit: 3, default: "xxx",         null: false
    t.text   "comments",                                            null: false
    t.text   "entered_by_whom",             default: "unspecified", null: false
    t.date   "date_entered"
    t.text   "data_provenance",                                     null: false
    t.text   "data_owned_by",               default: "unspecified", null: false
    t.text   "data_status",                 default: "unspecified", null: false
    t.text   "confirmed_by_whom",           default: "unspecified", null: false
  end

  add_index "plant_marker_variations", ["marker_variation"], name: "idx_143781_marker_variation", using: :btree
  add_index "plant_marker_variations", ["occasion"], name: "idx_143781_occasion", using: :btree

  create_table "plant_parts", id: false, force: :cascade do |t|
    t.text "plant_part"
    t.text "description",                               null: false
    t.text "described_by_whom", default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  create_table "plant_population_lists", force: :cascade do |t|
    t.integer "plant_population_id",                         null: false
    t.text    "plant_line_name",     default: "unspecified", null: false
    t.text    "sort_order",          default: "unspecified", null: false
    t.text    "comments",                                    null: false
    t.text    "entered_by_whom",     default: "unspecified", null: false
    t.date    "date_entered"
    t.text    "data_provenance",                             null: false
    t.text    "data_status",         default: "unspecified", null: false
    t.text    "confirmed_by_whom",   default: "unspecified", null: false
  end

  add_index "plant_population_lists", ["plant_line_name"], name: "idx_143830_plant_line", using: :btree

  create_table "plant_populations", primary_key: "plant_population_id", force: :cascade do |t|
    t.text "population_type",           default: "unspecified", null: false
    t.text "genus",                     default: "unspecified", null: false
    t.text "species",                   default: "unspecified", null: false
    t.text "female_parent_line",        default: "unspecified", null: false
    t.text "male_parent_line",          default: "unspecified", null: false
    t.text "canonical_population_name", default: "unspecified"
    t.text "description",                                       null: false
    t.date "date_established"
    t.text "established_by_whom",       default: "unspecified", null: false
    t.text "establishing_organisation", default: "unspecified", null: false
    t.text "population_owned_by",       default: "unspecified"
    t.text "comments"
    t.text "entered_by_whom",           default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_owned_by",             default: "unspecified", null: false
    t.text "data_provenance",                                   null: false
    t.text "data_status",               default: "unspecified", null: false
    t.text "confirmed_by_whom",         default: "unspecified", null: false
    t.text "plant_population_name",     default: "unspecified", null: false
    t.text "assigned_population_name",  default: "unspecified", null: false
  end

  create_table "plant_scoring_units", primary_key: "scoring_unit_id", force: :cascade do |t|
    t.text "plant_trial_id",           default: "unspecified", null: false
    t.text "design_factor_id",         default: "unspecified", null: false
    t.text "plant_accession",          default: "unspecified", null: false
    t.text "scored_plant_part",        default: "unspecified", null: false
    t.text "number_units_scored",      default: "unspecified", null: false
    t.text "scoring_unit_sample_size", default: "unspecified", null: false
    t.text "scoring_unit_frame_size",  default: "unspecified", null: false
    t.date "date_planted"
    t.text "seed_packet_id",           default: "unspecified", null: false
    t.text "described_by_whom",        default: "unspecified", null: false
    t.text "comments",                                         null: false
    t.text "entered_by_whom",          default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                  null: false
    t.text "data_owned_by",            default: "unspecified", null: false
    t.text "data_status",              default: "unspecified", null: false
    t.text "confirmed_by_whom",        default: "unspecified", null: false
  end

  add_index "plant_scoring_units", ["plant_accession"], name: "idx_143842_trial", using: :btree
  add_index "plant_scoring_units", ["scored_plant_part"], name: "idx_143842_row_plot_position", using: :btree

  create_table "plant_trial_collection_lists", primary_key: "plant_trial_collection_id", force: :cascade do |t|
    t.text "plant_trial_id",    default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  create_table "plant_trial_collections", primary_key: "plant_trial_collection_id", force: :cascade do |t|
    t.text "project_description",                            null: false
    t.text "collection_description",                         null: false
    t.text "collected_by_whom",      default: "unspecified", null: false
    t.text "comments",                                       null: false
    t.text "entered_by_whom",        default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                null: false
    t.text "data_status",            default: "unspecified", null: false
    t.text "confirmed_by_whom",      default: "unspecified", null: false
  end

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
    t.text   "altitude",                           default: "unspecified", null: false
    t.text   "terrain",                            default: "unspecified", null: false
    t.text   "soil_type",                          default: "unspecified", null: false
    t.text   "contact_person",                     default: "unspecified", null: false
    t.text   "design_type",                        default: "unspecified", null: false
    t.text   "statistical_factors",                                        null: false
    t.text   "design_factors",                                             null: false
    t.text   "design_layout_matrix",                                       null: false
    t.text   "comments",                                                   null: false
    t.text   "entered_by_whom",                    default: "unspecified", null: false
    t.date   "date_entered"
    t.text   "data_provenance",                                            null: false
    t.text   "data_owned_by",                      default: "unspecified", null: false
    t.text   "data_status",                        default: "unspecified", null: false
    t.text   "confirmed_by_whom",                  default: "unspecified", null: false
  end

  create_table "plant_varieties", id: false, force: :cascade do |t|
    t.text "plant_variety_name"
    t.text "genus",              default: "unspecified", null: false
    t.text "species",            default: "unspecified", null: false
    t.text "subtaxa",            default: "unspecified", null: false
    t.text "taxa_authority",     default: "unspecified", null: false
    t.text "subtaxa_authority",  default: "unspecified", null: false
    t.text "crop_type",          default: "unspecified", null: false
    t.text "comments",                                   null: false
    t.text "entered_by_whom",    default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                            null: false
    t.text "data_owned_by",      default: "unspecified", null: false
    t.text "data_status",        default: "unspecified", null: false
    t.text "confirmed_by_whom",  default: "unspecified", null: false
  end

  add_index "plant_varieties", ["plant_variety_name"], name: "idx_143909_plant_variety_name", using: :btree

  create_table "plant_variety_detail", id: false, force: :cascade do |t|
    t.text "plant_variety_name"
    t.text "data_attribution",      default: "unspecified", null: false
    t.text "country_of_origin",     default: "xxx",         null: false
    t.text "country_registered",    default: "xxx",         null: false
    t.text "year_registered",       default: "xxxx",        null: false
    t.text "breeder",               default: "unspecified", null: false
    t.text "breeders_variety_code", default: "unspecified", null: false
    t.text "agent",                 default: "unspecified", null: false
    t.text "owner",                 default: "unspecified", null: false
    t.text "quoted_parentage",                              null: false
    t.text "female_parent",         default: "unspecified", null: false
    t.text "male_parent",           default: "unspecified", null: false
    t.text "comments",                                      null: false
    t.text "entered_by_whom",       default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_owned_by",         default: "unspecified", null: false
    t.text "data_status",           default: "unspecified", null: false
    t.text "confirmed_by_whom",     default: "unspecified", null: false
    t.text "data_provenance",                               null: false
  end

  add_index "plant_variety_detail", ["data_attribution"], name: "idx_143926_data_provenance", using: :btree
  add_index "plant_variety_detail", ["plant_variety_name"], name: "idx_143926_plant_variety_name", using: :btree

  create_table "pop_locus_genotype_alleles", id: false, force: :cascade do |t|
    t.text "allele_number"
    t.text "plant_population",     default: "unspecified", null: false
    t.text "mapping_locus",        default: "unspecified", null: false
    t.text "locus_genotype",       default: "unspecified", null: false
    t.text "gametic_locus_allele", default: "unspecified", null: false
    t.text "allele_total",         default: "unspecified", null: false
    t.text "assigned_by_whom",     default: "unspecified", null: false
    t.date "date_assigned"
    t.text "comments",                                     null: false
    t.text "entered_by_whom",      default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                              null: false
    t.text "data_owned_by",        default: "unspecified", null: false
    t.text "data_status",          default: "unspecified", null: false
    t.text "confirmed_by_whom",    default: "unspecified", null: false
  end

  add_index "pop_locus_genotype_alleles", ["allele_number"], name: "idx_143991_allele_number", using: :btree
  add_index "pop_locus_genotype_alleles", ["gametic_locus_allele"], name: "idx_143991_locus_allele", using: :btree
  add_index "pop_locus_genotype_alleles", ["locus_genotype"], name: "idx_143991_locus_genotype", using: :btree
  add_index "pop_locus_genotype_alleles", ["mapping_locus"], name: "idx_143991_mapping_locus", using: :btree
  add_index "pop_locus_genotype_alleles", ["plant_population", "mapping_locus", "gametic_locus_allele"], name: "idx_143991_fk_population_locus_genotype_alleles_3", using: :btree
  add_index "pop_locus_genotype_alleles", ["plant_population", "mapping_locus", "locus_genotype", "allele_number"], name: "idx_143991_fk_population_locus_genotype_alleles_2", using: :btree
  add_index "pop_locus_genotype_alleles", ["plant_population"], name: "idx_143991_plant_population", using: :btree

  create_table "pop_type_lookup", id: false, force: :cascade do |t|
    t.text "population_type"
    t.text "population_class", default: "unspecified", null: false
    t.text "assigned_by_whom", default: "unspecified", null: false
  end

  create_table "population_genotypes", id: false, force: :cascade do |t|
    t.text "plant_population"
    t.text "mapping_locus",         default: "unspecified", null: false
    t.text "zygote_locus_genotype", default: "unspecified", null: false
    t.text "locus_code_system",     default: "unspecified", null: false
    t.text "comments",                                      null: false
    t.text "entered_by_whom",       default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                               null: false
    t.text "data_owned_by",         default: "unspecified", null: false
    t.text "data_status",           default: "unspecified", null: false
    t.text "confirmed_by_whom",     default: "unspecified", null: false
  end

  add_index "population_genotypes", ["mapping_locus"], name: "idx_143947_mapping_locus", using: :btree
  add_index "population_genotypes", ["plant_population"], name: "idx_143947_plant_population", using: :btree
  add_index "population_genotypes", ["zygote_locus_genotype"], name: "idx_143947_genotype", using: :btree

  create_table "population_loci", id: false, force: :cascade do |t|
    t.text "mapping_locus"
    t.text "plant_population",  default: "unspecified", null: false
    t.text "marker_assay_name", default: "unspecified", null: false
    t.text "defined_by_whom",   default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  add_index "population_loci", ["mapping_locus"], name: "idx_143961_mapping_locus", using: :btree
  add_index "population_loci", ["marker_assay_name"], name: "idx_143961_marker_assay", using: :btree
  add_index "population_loci", ["plant_population"], name: "idx_143961_plant_population", using: :btree

  create_table "population_locus_alleles", id: false, force: :cascade do |t|
    t.text "plant_population"
    t.text "mapping_locus",        default: "unspecified", null: false
    t.text "gametic_locus_allele", default: "unspecified", null: false
    t.text "marker_variation",     default: "unspecified", null: false
    t.text "allele_description",   default: "unspecified", null: false
    t.text "assigned_by_whom",     default: "unspecified", null: false
    t.date "date_assigned"
    t.text "comments",                                     null: false
    t.text "entered_by_whom",      default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                              null: false
    t.text "data_owned_by",        default: "unspecified", null: false
    t.text "data_status",          default: "unspecified", null: false
    t.text "confirmed_by_whom",    default: "unspecified", null: false
  end

  add_index "population_locus_alleles", ["gametic_locus_allele"], name: "idx_143975_allele", using: :btree
  add_index "population_locus_alleles", ["mapping_locus"], name: "idx_143975_mapping_locus", using: :btree
  add_index "population_locus_alleles", ["marker_variation"], name: "idx_143975_marker_variation", using: :btree
  add_index "population_locus_alleles", ["plant_population"], name: "idx_143975_plant_population", using: :btree

  create_table "primers", id: false, force: :cascade do |t|
    t.text "primer"
    t.text "sequence",                  default: "unspecified", null: false
    t.text "sequence_id",               default: "unspecified", null: false
    t.text "sequence_source_acronym",   default: "unspecified", null: false
    t.text "description",                                       null: false
    t.text "design_seq_id",             default: "unspecified", null: false
    t.text "design_seq_source_acronym", default: "unspecified", null: false
    t.text "reanneal_temp",             default: "unspecified", null: false
    t.text "designed_by_whom",          default: "unspecified", null: false
    t.text "comments",                                          null: false
    t.text "entered_by_whom",           default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                   null: false
    t.text "data_owned_by",             default: "unspecified", null: false
    t.text "data_status",               default: "unspecified", null: false
    t.text "confirmed_by_whom",         default: "unspecified", null: false
  end

  create_table "proccessed_trait_datasets", primary_key: "proccessed_trait_dataset_id", force: :cascade do |t|
    t.text "trial_id",                         default: "unspecified", null: false
    t.text "trait_descriptor_id",              default: "unspecified", null: false
    t.text "population_id",                    default: "unspecified", null: false
    t.text "raw_dataset_id",                   default: "unspecified", null: false
    t.text "raw_dataset_analysis_occasion_id", default: "unspecified", null: false
    t.text "processed_dataset_id",             default: "unspecified", null: false
    t.text "statistical_analysis_description",                         null: false
    t.text "trait_mean",                       default: "unspecified", null: false
    t.text "trait_total_variance",             default: "unspecified", null: false
    t.text "trait_additive_genetic_variance",  default: "unspecified", null: false
    t.text "trait_percent_heritability",       default: "unspecified", null: false
    t.text "residual_variance",                default: "unspecified", null: false
    t.text "average_sed",                      default: "unspecified", null: false
    t.text "line_mean_type",                   default: "unspecified", null: false
    t.text "comments",                                                 null: false
    t.text "entered_by_whom",                  default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                          null: false
    t.text "data_owned_by",                    default: "unspecified", null: false
    t.text "data_status",                      default: "unspecified", null: false
    t.text "confirmed_by_whom",                default: "unspecified", null: false
  end

  add_index "proccessed_trait_datasets", ["trial_id", "trait_descriptor_id", "population_id"], name: "idx_144065_trial_id", using: :btree

  create_table "processed_trait_datasets", primary_key: "processed_trait_dataset_id", force: :cascade do |t|
    t.text "trial_id",                      default: "unspecified", null: false
    t.text "trait_descriptor_id",           default: "unspecified", null: false
    t.text "population_id",                 default: "unspecified", null: false
    t.text "raw_dataset_id",                default: "unspecified", null: false
    t.text "raw_dataset_analysis_occasion", default: "unspecified", null: false
    t.text "processed_dataset_id",          default: "unspecified", null: false
    t.text "stats_analysis_description",                            null: false
    t.text "trait_mean",                    default: "unspecified", null: false
    t.text "trait_total_variance",          default: "unspecified", null: false
    t.text "additive_genetic_variance",     default: "unspecified", null: false
    t.text "trait_percent_heritability",    default: "unspecified", null: false
    t.text "residual_variance",             default: "unspecified", null: false
    t.text "average_sed",                   default: "unspecified", null: false
    t.text "line_mean_type",                default: "unspecified", null: false
    t.text "comments",                                              null: false
    t.text "entered_by_whom",               default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                       null: false
    t.text "data_owned_by",                 default: "unspecified", null: false
    t.text "data_status",                   default: "unspecified", null: false
    t.text "confirmed_by_whom",             default: "unspecified", null: false
  end

  add_index "processed_trait_datasets", ["trial_id", "trait_descriptor_id", "population_id"], name: "idx_144089_trial_id", using: :btree

  create_table "qtl", primary_key: "qtl_job_id", force: :cascade do |t|
    t.text "processed_trait_dataset_id", default: "unspecified", null: false
    t.text "linkage_group_id",           default: "unspecified", null: false
    t.text "qtl_rank",                   default: "unspecified", null: false
    t.text "map_qtl_label",              default: "unspecified", null: false
    t.text "outer_interval_start",       default: "unspecified", null: false
    t.text "inner_interval_start",       default: "unspecified", null: false
    t.text "qtl_mid_position",           default: "unspecified", null: false
    t.text "inner_interval_end",         default: "unspecified", null: false
    t.text "outer_interval_end",         default: "unspecified", null: false
    t.text "peak_value",                 default: "unspecified", null: false
    t.text "peak_p_value",               default: "unspecified", null: false
    t.text "regression_p",               default: "unspecified", null: false
    t.text "residual_p",                 default: "unspecified", null: false
    t.text "additive_effect",            default: "unspecified", null: false
    t.text "se_additive_effect",         default: "unspecified", null: false
    t.text "genetic_variance_explained", default: "unspecified", null: false
    t.text "comments",                                           null: false
    t.text "entered_by_whom",            default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                    null: false
    t.text "data_owned_by",              default: "unspecified", null: false
    t.text "data_status",                default: "unspecified", null: false
    t.text "confirmed_by_whom",          default: "unspecified", null: false
  end

  add_index "qtl", ["linkage_group_id"], name: "idx_144113_linkage_group", using: :btree
  add_index "qtl", ["processed_trait_dataset_id"], name: "idx_144113_trial", using: :btree

  create_table "qtl_jobs", primary_key: "qtl_job_id", force: :cascade do |t|
    t.text "linkage_map_id",                 default: "unspecified", null: false
    t.text "qtl_software",                   default: "unspecified", null: false
    t.text "qtl_method",                     default: "unspecified", null: false
    t.text "qtl_parameters",                                         null: false
    t.text "threshold_specification_method",                         null: false
    t.text "threshold_significance_level",   default: "unspecified", null: false
    t.text "interval_type",                  default: "unspecified", null: false
    t.text "inner_confidence_threshold",     default: "unspecified", null: false
    t.text "outer_confidence_threshold",     default: "unspecified", null: false
    t.text "qtl_statistic_type",             default: "unspecified", null: false
    t.text "described_by_whom",              default: "unspecified", null: false
    t.date "date_run"
    t.text "comments",                                               null: false
    t.text "entered_by_whom",                default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                        null: false
    t.text "data_owned_by",                  default: "unspecified", null: false
    t.text "data_status",                    default: "unspecified", null: false
    t.text "confirmed_by_whom",              default: "unspecified", null: false
  end

  add_index "qtl_jobs", ["linkage_map_id"], name: "idx_144140_linkage_map_id", using: :btree
  add_index "qtl_jobs", ["qtl_software", "qtl_method"], name: "idx_144140_qtl_software", using: :btree

  create_table "restriction_enzymes", id: false, force: :cascade do |t|
    t.text "restriction_enzyme"
    t.text "recognition_site",   default: "unspecified", null: false
    t.text "data_provenance",                            null: false
  end

  create_table "row_plot_positions", primary_key: "row_plot_position_id", force: :cascade do |t|
    t.text "institute_id",      default: "unspecified", null: false
    t.text "field_name",        default: "unspecified", null: false
    t.text "block_name",        default: "unspecified", null: false
    t.text "row_plot_name",     default: "unspecified", null: false
    t.text "row_plot_position", default: "unspecified", null: false
    t.text "plant_density",     default: "",            null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  add_index "row_plot_positions", ["institute_id"], name: "idx_144168_institute", using: :btree

  create_table "scoring_occasions", primary_key: "scoring_occasion_id", force: :cascade do |t|
    t.date "score_start_date"
    t.date "score_end_date"
    t.text "scored_by_whom",    default: "unspecified", null: false
    t.text "recorded_by_whom",  default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
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
  add_index "taxonomy_terms", ["name"], name: "index_taxonomy_terms_on_name", using: :btree
  add_index "taxonomy_terms", ["taxonomy_term_id"], name: "index_taxonomy_terms_on_taxonomy_term_id", using: :btree

  create_table "trait_descriptors", primary_key: "trait_descriptor_id", force: :cascade do |t|
    t.text "category",                 default: "unspecified", null: false
    t.text "descriptor_name",          default: "unspecified", null: false
    t.text "units_of_measurements",    default: "unspecified", null: false
    t.text "where_to_score",                                   null: false
    t.text "scoring_method",                                   null: false
    t.text "when_to_score",            default: "unspecified", null: false
    t.text "stage_scored",             default: "unspecified", null: false
    t.text "precautions",                                      null: false
    t.text "materials",                                        null: false
    t.text "controls",                                         null: false
    t.text "calibrated_against"
    t.text "instrumentation_required",                         null: false
    t.text "likely_ambiguities",                               null: false
    t.text "contact_person",           default: "unspecified", null: false
    t.date "date_method_agreed"
    t.text "score_type",               default: "unspecified", null: false
    t.text "related_trait_ids"
    t.text "related_characters"
    t.text "possible_interactions",                            null: false
    t.text "authorities",              default: "unspecified", null: false
    t.text "comments",                                         null: false
    t.text "entered_by_whom",          default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                  null: false
    t.text "data_owned_by",            default: "unspecified", null: false
    t.text "data_status",              default: "unspecified", null: false
    t.text "confirmed_by_whom",        default: "unspecified", null: false
  end

  add_index "trait_descriptors", ["category"], name: "idx_144197_category", using: :btree
  add_index "trait_descriptors", ["descriptor_name"], name: "idx_144197_descriptor_name", using: :btree
  add_index "trait_descriptors", ["trait_descriptor_id"], name: "idx_144197_trait_descriptor_id", using: :btree

  create_table "trait_grades", primary_key: "trait_descriptor_id", force: :cascade do |t|
    t.text "trait_grade",       default: "unspecified", null: false
    t.text "description",                               null: false
    t.text "described_by_whom", default: "unspecified", null: false
    t.text "comments",                                  null: false
    t.text "entered_by_whom",   default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                           null: false
    t.text "data_owned_by",     default: "unspecified", null: false
    t.text "data_status",       default: "unspecified", null: false
    t.text "confirmed_by_whom", default: "unspecified", null: false
  end

  create_table "trait_scores", primary_key: "scoring_unit_id", force: :cascade do |t|
    t.text "scoring_occasion_id",     default: "unspecified", null: false
    t.text "trait_descriptor_id",     default: "unspecified", null: false
    t.text "replicate_score_reading", default: "unspecified", null: false
    t.text "score_value"
    t.text "score_spread",            default: "unspecified", null: false
    t.text "value_type",              default: "unspecified", null: false
    t.text "spread_type",             default: "unspecified", null: false
    t.text "comments",                                        null: false
    t.text "entered_by_whom",         default: "unspecified", null: false
    t.date "date_entered"
    t.text "data_provenance",                                 null: false
    t.text "data_owned_by",           default: "unspecified", null: false
    t.text "data_status",             default: "unspecified", null: false
    t.text "confirmed_by_whom",       default: "unspecified", null: false
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

  create_table "version", id: false, force: :cascade do |t|
    t.text "version"
    t.date "date"
    t.text "updated_by_whom", default: "unspecified", null: false
    t.text "comments",                                null: false
  end

end
