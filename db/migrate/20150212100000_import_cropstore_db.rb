class ImportCropstoreDb < ActiveRecord::Migration
  def change
    ActiveRecord::Schema.define(version: 0) do

      # These are extensions that must be enabled in order to support this database
      enable_extension "plpgsql"

      create_table "countries", id: false, force: :cascade do |t|
        t.text "country_code",    primary: true
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
        t.text "data_status",         default: "unspecified", null: false
        t.text "confirmed_by_whom"
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
      end

      create_table "linkage_groups", primary_key: "linkage_group_id", force: :cascade do |t|
        t.text "linkage_group_name",          default: "unspecified", null: false
        t.text "total_length"
        t.text "lod_threshold"
        t.text "consensus_group_assignment",  default: "unspecified", null: false
        t.text "consensus_group_orientation"
        t.text "comments",                                            null: false
        t.text "entered_by_whom",             default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                     null: false
        t.text "data_owned_by",               default: "unspecified", null: false
        t.text "data_status",                 default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      add_index "linkage_groups", ["linkage_group_name"], name: "idx_143534_linkage_group_name", using: :btree

      create_table "linkage_maps", primary_key: "linkage_map_id", force: :cascade do |t|
        t.text   "linkage_map_name",             default: "unspecified", null: false
        t.text   "mapping_population",           default: "unspecified", null: false
        t.string "map_version_no",     limit: 3, default: "xxx",         null: false
        t.date   "map_version_date"
        t.text   "mapping_software"
        t.text   "mapping_function"
        t.text   "map_author"
        t.text   "comments",                                             null: false
        t.text   "entered_by_whom",              default: "unspecified", null: false
        t.date   "date_entered"
        t.text   "data_provenance",                                      null: false
        t.text   "data_owned_by",                default: "unspecified", null: false
        t.text   "data_status",                  default: "unspecified", null: false
        t.text   "confirmed_by_whom"
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
        t.text "map_position",               default: "unspecified"
        t.text "map_data_status",            default: "unspecified", null: false
        t.text "associated_sequence_id",     default: "unspecified", null: false
        t.text "sequence_source_acronym",    default: "unspecified", null: false
        t.text "cs_sequence_data_status",    default: "unspecified", null: false
        t.text "sqs_sequence_data_status",   default: "unspecified", null: false
        t.text "atg_hit_seq_id"
        t.text "atg_hit_seq_source"
        t.text "bac_hit_seq_id"
        t.text "bac_hit_seq_source"
        t.text "bac_hit_name"
      end

      create_table "map_positions", primary_key: "linkage_group_id", force: :cascade do |t|
        t.text "marker_assay_name", default: "unspecified", null: false
        t.text "mapping_locus",     default: "unspecified", null: false
        t.text "map_position"
        t.text "comments",                                  null: false
        t.text "entered_by_whom",   default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                           null: false
        t.text "data_owned_by",     default: "unspecified", null: false
        t.text "data_status",       default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      add_index "map_positions", ["map_position"], name: "idx_143597_map_position", using: :btree
      add_index "map_positions", ["mapping_locus"], name: "idx_143597_mapping_locus", using: :btree

      create_table "marker_assays", id: false, force: :cascade do |t|
        t.text "marker_assay_name",          primary: true
        t.text "canonical_marker_name",      default: "unspecified", null: false
        t.text "marker_type"
        t.text "probe_name"
        t.text "primer_a"
        t.text "primer_b"
        t.text "separation_system"
        t.text "comments",                                           null: false
        t.text "entered_by_whom",            default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance"
        t.text "data_owned_by",              default: "unspecified", null: false
        t.text "data_status",                default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      create_table "marker_sequence_assignments", id: false, force: :cascade do |t|
        t.text "canonical_marker_name",   primary: true
        t.text "marker_set",              default: "unspecified", null: false
        t.text "associated_sequence_id"
        t.text "sequence_source_acronym"
        t.text "comments"
        t.text "entered_by_whom",         default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance"
        t.text "data_owned_by"
        t.text "data_status",             default: "unspecified", null: false
      end

      add_index "marker_sequence_assignments", ["canonical_marker_name"], name: "idx_143632_canonical_marker_name", using: :btree

      create_table "occasions", primary_key: "occasion_id", force: :cascade do |t|
        t.date "start_date"
        t.text "start_time"
        t.date "end_date"
        t.text "end_time"
        t.text "scored_by_whom"
        t.text "recorded_by_whom"
        t.text "comments",                                  null: false
        t.text "entered_by_whom",   default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                           null: false
        t.text "data_owned_by",     default: "unspecified", null: false
        t.text "data_status",       default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      create_table "plant_accessions", id: false, force: :cascade do |t|
        t.text "plant_accession",            primary: true
        t.text "plant_line_name",            default: "unspecified", null: false
        t.text "plant_accession_derivation"
        t.text "accession_originator"
        t.text "originating_organisation"
        t.text "year_produced",              default: "xxxx",        null: false
        t.date "date_harvested"
        t.text "female_parent_plant_id"
        t.text "male_parent_plant_id"
        t.text "comments",                                           null: false
        t.text "entered_by_whom",            default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                    null: false
        t.text "data_owned_by",              default: "unspecified", null: false
        t.text "data_status",                default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      add_index "plant_accessions", ["plant_line_name"], name: "idx_143691_plant_line", using: :btree

      create_table "plant_lines", id: false, force: :cascade do |t|
        t.text "plant_line_name",    primary: true
        t.text "common_name"
        t.text "plant_variety_name"
        t.text "named_by_whom"
        t.text "organisation"
        t.text "genetic_status"
        t.text "previous_line_name"
        t.text "comments",                                   null: false
        t.text "entered_by_whom",    default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance"
        t.text "data_owned_by"
        t.text "data_status",        default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      add_index "plant_lines", ["plant_variety_name"], name: "idx_143729_plant_variety", using: :btree

      create_table "plant_parts", id: false, force: :cascade do |t|
        t.text "plant_part",        primary: true
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
        t.integer "plant_population_id", null: false
        t.text "plant_line_name",   default: "unspecified", null: false
        t.text "sort_order",        default: "unspecified", null: false
        t.text "comments",                                  null: false
        t.text "entered_by_whom",   default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance"
        t.text "data_status",       default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      add_index "plant_population_lists", ["plant_line_name"], name: "idx_143830_plant_line", using: :btree

      create_table "plant_populations", primary_key: "plant_population_id", force: :cascade do |t|
        t.text "population_type"
        t.text "genus",                     default: "unspecified", null: false
        t.text "species",                   default: "unspecified", null: false
        t.text "female_parent_line"
        t.text "male_parent_line"
        t.text "canonical_population_name", default: "unspecified"
        t.text "description"
        t.date "date_established"
        t.text "established_by_whom"
        t.text "establishing_organisation"
        t.text "population_owned_by"
        t.text "comments"
        t.text "entered_by_whom",           default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_owned_by"
        t.text "data_provenance"
        t.text "data_status",               default: "unspecified", null: false
        t.text "confirmed_by_whom"
        t.text "plant_population_name",     default: "unspecified", null: false
        t.text "assigned_population_name",  default: "unspecified", null: false
      end

      create_table "plant_scoring_units", primary_key: "scoring_unit_id", force: :cascade do |t|
        t.text "plant_trial_id",           default: "unspecified", null: false
        t.text "design_factor_id",         default: "unspecified", null: false
        t.text "plant_accession",          default: "unspecified", null: false
        t.text "scored_plant_part",        default: "unspecified", null: false
        t.text "number_units_scored"
        t.text "scoring_unit_sample_size"
        t.text "scoring_unit_frame_size"
        t.date "date_planted"
        t.text "described_by_whom"
        t.text "comments",                                         null: false
        t.text "entered_by_whom",          default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                  null: false
        t.text "data_owned_by",            default: "unspecified", null: false
        t.text "data_status",              default: "unspecified", null: false
        t.text "confirmed_by_whom"
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
        t.text   "altitude"
        t.text   "terrain"
        t.text   "soil_type"
        t.text   "contact_person",                     default: "unspecified", null: false
        t.text   "design_type"
        t.text   "statistical_factors"
        t.text   "design_factors"
        t.text   "design_layout_matrix"
        t.text   "comments",                                                   null: false
        t.text   "entered_by_whom",                    default: "unspecified", null: false
        t.date   "date_entered"
        t.text   "data_provenance",                                            null: false
        t.text   "data_owned_by",                      default: "unspecified", null: false
        t.text   "data_status",                        default: "unspecified", null: false
        t.text   "confirmed_by_whom"
      end

      create_table "plant_varieties", id: false, force: :cascade do |t|
        t.text "plant_variety_name", primary: true
        t.text "genus",              default: "unspecified", null: false
        t.text "species",            default: "unspecified", null: false
        t.text "subtaxa"
        t.text "crop_type"
        t.text "comments",                                   null: false
        t.text "entered_by_whom",    default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                            null: false
        t.text "data_status",        default: "unspecified", null: false
      end

      add_index "plant_varieties", ["plant_variety_name"], name: "idx_143909_plant_variety_name", using: :btree

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
        t.text "data_status",           default: "unspecified", null: false
        t.text "data_provenance"
      end

      add_index "plant_variety_detail", ["data_attribution"], name: "idx_143926_data_provenance", using: :btree
      add_index "plant_variety_detail", ["plant_variety_name"], name: "idx_143926_plant_variety_name", using: :btree

      create_table "pop_type_lookup", id: false, force: :cascade do |t|
        t.text "population_type",  primary: true
        t.text "population_class", default: "unspecified", null: false
        t.text "assigned_by_whom", default: "unspecified", null: false
      end

      create_table "population_loci", id: false, force: :cascade do |t|
        t.text "mapping_locus",     primary: true
        t.text "plant_population",  default: "unspecified", null: false
        t.text "marker_assay_name", default: "unspecified", null: false
        t.text "defined_by_whom"
        t.text "comments"
        t.text "entered_by_whom",   default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                           null: false
        t.text "data_owned_by",     default: "unspecified", null: false
        t.text "data_status",       default: "unspecified", null: false
      end

      add_index "population_loci", ["mapping_locus"], name: "idx_143961_mapping_locus", using: :btree
      add_index "population_loci", ["marker_assay_name"], name: "idx_143961_marker_assay", using: :btree
      add_index "population_loci", ["plant_population"], name: "idx_143961_plant_population", using: :btree

      create_table "primers", id: false, force: :cascade do |t|
        t.text "primer",                    primary: true
        t.text "sequence",                  default: "unspecified", null: false
        t.text "sequence_id",               default: "unspecified", null: false
        t.text "sequence_source_acronym",   default: "unspecified", null: false
        t.text "description"
        t.text "comments",                                          null: false
        t.text "entered_by_whom",           default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                   null: false
        t.text "data_owned_by"
        t.text "data_status",               default: "unspecified", null: false
      end

      create_table "probes", id: false, force: :cascade do |t|
        t.text "probe_name",                primary: true
        t.text "species",                   default: "unspecified", null: false
        t.text "pcr_yes_or_no",             default: "N", null: false
        t.text "clone_name"
        t.date "date_described"
        t.text "sequence_id"
        t.text "sequence_source_acronym",   default: "unspecified", null: false
        t.text "comments"
        t.text "entered_by_whom",           default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance"
        t.text "data_status",               default: "unspecified", null: false
      end

      create_table "processed_trait_datasets", primary_key: "processed_trait_dataset_id", force: :cascade do |t|
        t.text "trial_id",                      default: "unspecified", null: false
        t.text "trait_descriptor_id",           default: "unspecified", null: false
        t.text "population_id",                 default: "unspecified", null: false
        t.text "processed_dataset_id"
        t.text "trait_percent_heritability"
        t.text "comments",                                              null: false
        t.text "entered_by_whom",               default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                       null: false
        t.text "data_owned_by",                 default: "unspecified", null: false
        t.text "data_status",                   default: "unspecified", null: false
      end

      add_index "processed_trait_datasets", ["trial_id", "trait_descriptor_id", "population_id"], name: "idx_144089_trial_id", using: :btree

      create_table "qtl", primary_key: "qtl_job_id", force: :cascade do |t|
        t.text "processed_trait_dataset_id", default: "unspecified", null: false
        t.text "linkage_group_id",           default: "unspecified", null: false
        t.text "qtl_rank",                   default: "unspecified", null: false
        t.text "map_qtl_label",              default: "unspecified", null: false
        t.text "outer_interval_start"
        t.text "inner_interval_start"
        t.text "qtl_mid_position",           default: "unspecified", null: false
        t.text "inner_interval_end"
        t.text "outer_interval_end"
        t.text "peak_value"
        t.text "peak_p_value"
        t.text "regression_p"
        t.text "residual_p"
        t.text "additive_effect",            default: "unspecified", null: false
        t.text "genetic_variance_explained"
        t.text "comments",                                           null: false
        t.text "entered_by_whom",            default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                    null: false
        t.text "data_owned_by",              default: "unspecified", null: false
        t.text "data_status",                default: "unspecified", null: false
      end

      add_index "qtl", ["linkage_group_id"], name: "idx_144113_linkage_group", using: :btree
      add_index "qtl", ["processed_trait_dataset_id"], name: "idx_144113_trial", using: :btree

      create_table "qtl_jobs", primary_key: "qtl_job_id", force: :cascade do |t|
        t.text "linkage_map_id",                 default: "unspecified", null: false
        t.text "qtl_software",                   default: "unspecified", null: false
        t.text "qtl_method",                     default: "unspecified", null: false
        t.text "threshold_specification_method"
        t.text "interval_type"
        t.text "inner_confidence_threshold"
        t.text "outer_confidence_threshold"
        t.text "qtl_statistic_type"
        t.text "described_by_whom"
        t.date "date_run"
        t.text "comments",                                               null: false
        t.text "entered_by_whom",                default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                        null: false
        t.text "data_owned_by",                  default: "unspecified", null: false
        t.text "data_status",                    default: "unspecified", null: false
      end

      add_index "qtl_jobs", ["linkage_map_id"], name: "idx_144140_linkage_map_id", using: :btree
      add_index "qtl_jobs", ["qtl_software", "qtl_method"], name: "idx_144140_qtl_software", using: :btree

      create_table "restriction_enzymes", id: false, force: :cascade do |t|
        t.text "restriction_enzyme",                       primary: true
        t.text "recognition_site", default: "unspecified", null: false
        t.text "data_provenance",                          null: false
      end

      create_table "scoring_occasions", primary_key: "scoring_occasion_id", force: :cascade do |t|
        t.date "score_start_date"
        t.date "score_end_date"
        t.text "comments",                                  null: false
        t.text "entered_by_whom",   default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                           null: false
        t.text "data_owned_by",     default: "unspecified", null: false
        t.text "data_status",       default: "unspecified", null: false
      end

      create_table "trait_descriptors", primary_key: "trait_descriptor_id", force: :cascade do |t|
        t.text "category",                 default: "unspecified", null: false
        t.text "descriptor_name",          default: "unspecified", null: false
        t.text "units_of_measurements"
        t.text "where_to_score",                                   null: false
        t.text "scoring_method"
        t.text "when_to_score"
        t.text "stage_scored"
        t.text "precautions"
        t.text "materials"
        t.text "controls"
        t.text "calibrated_against"
        t.text "instrumentation_required"
        t.text "likely_ambiguities"
        t.text "contact_person"
        t.date "date_method_agreed"
        t.text "score_type"
        t.text "related_trait_ids"
        t.text "related_characters"
        t.text "possible_interactions"
        t.text "authorities"
        t.text "comments",                                         null: false
        t.text "entered_by_whom",          default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                  null: false
        t.text "data_owned_by",            default: "unspecified", null: false
        t.text "data_status",              default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      add_index "trait_descriptors", ["category"], name: "idx_144197_category", using: :btree
      add_index "trait_descriptors", ["descriptor_name"], name: "idx_144197_descriptor_name", using: :btree
      add_index "trait_descriptors", ["trait_descriptor_id"], name: "idx_144197_trait_descriptor_id", using: :btree

      create_table "trait_grades", primary_key: "trait_descriptor_id", force: :cascade do |t|
        t.text "trait_grade",       default: "unspecified", null: false
        t.text "description",                               null: false
        t.text "comments",                                  null: false
        t.text "entered_by_whom",   default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                           null: false
        t.text "data_status",       default: "unspecified", null: false
      end

      create_table "trait_scores", primary_key: "scoring_unit_id", force: :cascade do |t|
        t.text "scoring_occasion_id",     default: "unspecified", null: false
        t.text "trait_descriptor_id",     default: "unspecified", null: false
        t.text "replicate_score_reading", default: "unspecified", null: false
        t.text "score_value"
        t.text "score_spread"
        t.text "value_type"
        t.text "comments",                                        null: false
        t.text "entered_by_whom",         default: "unspecified", null: false
        t.date "date_entered"
        t.text "data_provenance",                                 null: false
        t.text "data_owned_by",           default: "unspecified", null: false
        t.text "data_status",             default: "unspecified", null: false
        t.text "confirmed_by_whom"
      end

      add_index "trait_scores", ["scoring_occasion_id"], name: "idx_144229_scoring_occasion", using: :btree
      add_index "trait_scores", ["trait_descriptor_id"], name: "idx_144229_trait_descriptor", using: :btree

      create_table "version", id: false, force: :cascade do |t|
        t.text "version",         primary: true
        t.date "date"
        t.text "updated_by_whom", default: "unspecified", null: false
        t.text "comments",                                null: false
      end

    end


  end
end
