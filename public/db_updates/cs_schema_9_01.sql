-- MySQL dump 10.16  Distrib 10.1.9-MariaDB, for Win32 (AMD64)
--
-- Host: localhost    Database: cs_brassica
-- ------------------------------------------------------
-- Server version	10.1.9-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `clone_libraries`
--

DROP TABLE IF EXISTS `clone_libraries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clone_libraries` (
  `library_name` varchar(20) NOT NULL DEFAULT '',
  `library_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `genus` varchar(100) NOT NULL DEFAULT 'unspecified',
  `species` varchar(100) NOT NULL DEFAULT 'unspecified',
  `subspecies` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_accession` varchar(70) DEFAULT NULL,
  `tissue` varchar(100) NOT NULL DEFAULT 'unspecified',
  `made_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `where_made` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_made` date NOT NULL DEFAULT '0000-00-00',
  `plant_growth_location` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_growth_conditions` longtext NOT NULL,
  `plant_treatment_details` longtext NOT NULL,
  `plant_stage_sampled` varchar(15) NOT NULL DEFAULT 'unspecified',
  `plant_amount_sampled` varchar(100) NOT NULL DEFAULT 'unspecified',
  `date_sampled` date NOT NULL DEFAULT '0000-00-00',
  `plant_tissue_storage_method` varchar(100) NOT NULL DEFAULT 'unspecified',
  `rna_preparation` varchar(100) NOT NULL DEFAULT 'unspecified',
  `dna_preparation` varchar(100) NOT NULL DEFAULT 'unspecified',
  `bacterial_strain` varchar(100) NOT NULL DEFAULT 'unspecified',
  `vector` varchar(100) NOT NULL DEFAULT 'unspecified',
  `cloning_site` varchar(100) NOT NULL DEFAULT 'unspecified',
  `antibiotic_selection` varchar(100) NOT NULL DEFAULT 'unspecified',
  `number_of_clones` varchar(15) NOT NULL DEFAULT 'unspecified',
  `plate_format_picked_into` varchar(100) NOT NULL DEFAULT 'unspecified',
  `library_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `library_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  PRIMARY KEY (`library_name`),
  KEY `species` (`species`),
  KEY `genus` (`genus`),
  KEY `library_type` (`library_type`),
  KEY `FK_clone_libraries_1` (`plant_accession`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clones`
--

DROP TABLE IF EXISTS `clones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clones` (
  `clone_name` varchar(100) NOT NULL DEFAULT '',
  `library_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  `clone_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `gene` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sequence_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sequence_source_acronym` varchar(35) NOT NULL DEFAULT 'unspecified',
  `description` longtext NOT NULL,
  `donor_name` varchar(90) NOT NULL DEFAULT 'unspecified',
  `donor_date` date NOT NULL DEFAULT '0000-00-00',
  `insert_length_bp` varchar(15) NOT NULL DEFAULT 'unspecified',
  `curated_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `curated_location` varchar(100) NOT NULL DEFAULT 'unspecified',
  `archived_location` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`clone_name`),
  KEY `FK_clones_1` (`library_name`),
  KEY `clone_type` (`clone_type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countries` (
  `country_code` char(3) NOT NULL DEFAULT '',
  `country_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `data_provenance` longtext NOT NULL,
  `comments` longtext NOT NULL,
  PRIMARY KEY (`country_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_additional_information`
--

DROP TABLE IF EXISTS `cs_additional_information`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_additional_information` (
  `table_name` varchar(50) NOT NULL DEFAULT 'unspecified',
  `single_key_field` varchar(50) NOT NULL DEFAULT 'unspecified',
  `key_value` varchar(100) NOT NULL DEFAULT 'unspecified',
  `additional_count` varchar(15) NOT NULL DEFAULT 'unspecified',
  `additional_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `additional_information` longtext NOT NULL,
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`table_name`,`single_key_field`,`key_value`,`additional_count`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_images`
--

DROP TABLE IF EXISTS `cs_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_images` (
  `cs_image_id` varchar(50) NOT NULL DEFAULT '',
  `image_filename` varchar(50) NOT NULL DEFAULT 'unspecified',
  `image_filepath` text NOT NULL,
  `image_description` longtext NOT NULL,
  `image_created_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `copyright_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `image_owned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`cs_image_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_images_lookup`
--

DROP TABLE IF EXISTS `cs_images_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_images_lookup` (
  `cs_image_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_database` varchar(100) NOT NULL DEFAULT 'unspecified',
  `cs_table` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_key_field` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_value` varchar(100) NOT NULL DEFAULT 'unspecified',
  `assigned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`cs_image_id`,`cs_database`,`cs_table`,`cs_key_field`,`cs_value`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_institutions`
--

DROP TABLE IF EXISTS `cs_institutions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_institutions` (
  `cs_institution_id` varchar(90) NOT NULL DEFAULT '',
  `institution_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `institution_address1` varchar(255) NOT NULL DEFAULT 'unspecified',
  `institution_address2` varchar(255) NOT NULL DEFAULT 'unspecified',
  `town` varchar(100) NOT NULL DEFAULT 'unspecified',
  `county_district` varchar(100) NOT NULL DEFAULT 'unspecified',
  `zip_postcode` varchar(15) NOT NULL DEFAULT 'unspecified',
  `country_id` char(3) NOT NULL DEFAULT 'xxx',
  `website` text,
  `previous_institution_id` varchar(90) DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`cs_institution_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_people`
--

DROP TABLE IF EXISTS `cs_people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_people` (
  `cs_person_id` varchar(90) NOT NULL DEFAULT '',
  `first_name` varchar(50) NOT NULL DEFAULT 'unspecified',
  `first_initials` varchar(15) NOT NULL DEFAULT 'unspecified',
  `surname` varchar(50) NOT NULL DEFAULT 'unspecified',
  `full_name` varchar(150) NOT NULL DEFAULT 'unspecified',
  `current_institution_id` varchar(90) NOT NULL DEFAULT 'unspecified',
  `department` varchar(100) NOT NULL DEFAULT 'unspecified',
  `role` varchar(100) NOT NULL DEFAULT 'unspecified',
  `phone_number` varchar(30) NOT NULL DEFAULT 'unspecified',
  `fax_number` varchar(30) NOT NULL DEFAULT 'unspecified',
  `current_email` text NOT NULL,
  `homepage` text NOT NULL,
  `previous_institution_id` varchar(90) NOT NULL DEFAULT 'unspecified',
  `previous_email` text NOT NULL,
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`cs_person_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_publications`
--

DROP TABLE IF EXISTS `cs_publications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_publications` (
  `cs_publication_id` varchar(50) NOT NULL DEFAULT '',
  `first_author` varchar(90) NOT NULL DEFAULT 'unspecified',
  `remaining_authors` longtext NOT NULL,
  `coresponding_author` varchar(90) NOT NULL DEFAULT 'unspecified',
  `year_published` varchar(4) NOT NULL DEFAULT 'xxxx',
  `journal` varchar(100) NOT NULL DEFAULT 'unspecified',
  `paper_title` longtext NOT NULL,
  `doi` text NOT NULL,
  `pmid` varchar(15) NOT NULL DEFAULT 'unspecified',
  `url` text NOT NULL,
  `reference_summary` longtext NOT NULL,
  `assigned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`cs_publication_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_publications_lookup`
--

DROP TABLE IF EXISTS `cs_publications_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_publications_lookup` (
  `cs_publication_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_database` varchar(100) NOT NULL DEFAULT 'unspecified',
  `cs_table` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_key_field` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_value` varchar(100) NOT NULL DEFAULT 'unspecified',
  `assigned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`cs_publication_id`,`cs_database`,`cs_table`,`cs_key_field`,`cs_value`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cs_synonyms`
--

DROP TABLE IF EXISTS `cs_synonyms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cs_synonyms` (
  `cs_synonym_id` varchar(50) NOT NULL DEFAULT '',
  `cs_database` varchar(100) NOT NULL DEFAULT 'unspecified',
  `cs_table` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_key_field` varchar(50) NOT NULL DEFAULT 'unspecified',
  `cs_value` varchar(100) NOT NULL DEFAULT 'unspecified',
  `synonym_value` varchar(100) NOT NULL DEFAULT 'unspecified',
  `synonym_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`cs_synonym_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `design_factors`
--

DROP TABLE IF EXISTS `design_factors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `design_factors` (
  `design_factor_id` varchar(100) NOT NULL DEFAULT '',
  `institute_id` varchar(90) NOT NULL DEFAULT 'unspecified',
  `trial_location_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `design_unit_counter` varchar(15) NOT NULL DEFAULT 'unspecified',
  `design_factor_1` varchar(50) NOT NULL DEFAULT 'unspecified',
  `design_factor_2` varchar(50) NOT NULL DEFAULT 'unspecified',
  `design_factor_3` varchar(50) NOT NULL DEFAULT 'unspecified',
  `design_factor_4` varchar(50) NOT NULL DEFAULT 'unspecified',
  `design_factor_5` varchar(50) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`design_factor_id`),
  KEY `institute_id` (`institute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `genotype_matrices`
--

DROP TABLE IF EXISTS `genotype_matrices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `genotype_matrices` (
  `linkage_map_id` varchar(30) NOT NULL DEFAULT '',
  `martix_complied_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `original_file_name` varchar(255) NOT NULL DEFAULT 'unspecified',
  `date_matrix_available` date NOT NULL DEFAULT '0000-00-00',
  `number_markers_in_matrix` varchar(15) NOT NULL DEFAULT 'unspecified',
  `number_lines_in_matrix` varchar(15) NOT NULL DEFAULT 'unspecified',
  `matrix` longtext NOT NULL,
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`linkage_map_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linkage_groups`
--

DROP TABLE IF EXISTS `linkage_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `linkage_groups` (
  `linkage_group_id` varchar(30) NOT NULL DEFAULT '',
  `linkage_group_name` varchar(15) NOT NULL DEFAULT 'unspecified',
  `total_length` varchar(15) NOT NULL DEFAULT 'unspecified',
  `lod_threshold` varchar(15) NOT NULL DEFAULT 'unspecified',
  `consensus_group_assignment` varchar(100) NOT NULL DEFAULT 'unspecified',
  `consensus_group_orientation` varchar(15) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified' COMMENT 'institution or organisation',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`linkage_group_id`),
  KEY `linkage_group_name` (`linkage_group_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linkage_maps`
--

DROP TABLE IF EXISTS `linkage_maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `linkage_maps` (
  `linkage_map_id` varchar(30) NOT NULL DEFAULT '',
  `linkage_map_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `mapping_population` varchar(20) NOT NULL DEFAULT 'unspecified',
  `map_version_no` char(3) NOT NULL DEFAULT 'xxx',
  `map_version_date` date NOT NULL DEFAULT '0000-00-00',
  `mapping_software` varchar(100) NOT NULL DEFAULT 'unspecified',
  `mapping_function` varchar(100) NOT NULL DEFAULT 'unspecified',
  `map_author` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`linkage_map_id`),
  KEY `mapping_population` (`mapping_population`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_linkage_group_lists`
--

DROP TABLE IF EXISTS `map_linkage_group_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_linkage_group_lists` (
  `linkage_map_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `linkage_group_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  PRIMARY KEY (`linkage_map_id`,`linkage_group_id`),
  KEY `linkage_group_id` (`linkage_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 PACK_KEYS=0;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_locus_hits`
--

DROP TABLE IF EXISTS `map_locus_hits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_locus_hits` (
  `linkage_map_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `linkage_group_id` varchar(30) NOT NULL DEFAULT '',
  `consensus_group_assignment` varchar(100) NOT NULL DEFAULT 'unspecified',
  `mapping_locus` varchar(20) NOT NULL DEFAULT '',
  `canonical_marker_name` varchar(15) NOT NULL DEFAULT 'unspecified',
  `map_position` varchar(15) NOT NULL DEFAULT 'unspecified',
  `map_data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `associated_sequence_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sequence_source_acronym` varchar(35) NOT NULL DEFAULT 'unspecified',
  `cs_sequence_data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sqs_sequence_data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `atg_hit_seq_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `atg_hit_seq_source` varchar(35) NOT NULL DEFAULT 'unspecified',
  `bac_hit_seq_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `bac_hit_seq_source` varchar(35) NOT NULL DEFAULT 'unspecified',
  `bac_hit_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`linkage_group_id`,`mapping_locus`,`map_position`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_positions`
--

DROP TABLE IF EXISTS `map_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_positions` (
  `linkage_group_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `marker_assay_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  `mapping_locus` varchar(20) NOT NULL DEFAULT 'unspecified',
  `map_position` varchar(15) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`linkage_group_id`,`mapping_locus`,`map_position`),
  KEY `mapping_locus` (`mapping_locus`),
  KEY `map_position` (`map_position`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marker_assays`
--

DROP TABLE IF EXISTS `marker_assays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marker_assays` (
  `marker_assay_name` varchar(20) NOT NULL DEFAULT '',
  `canonical_marker_name` varchar(15) NOT NULL DEFAULT 'unspecified',
  `marker_type` varchar(15) NOT NULL DEFAULT 'unspecified',
  `probe_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  `primer_A` varchar(20) NOT NULL DEFAULT 'unspecified',
  `primer_B` varchar(20) NOT NULL DEFAULT 'unspecified',
  `restriction_enzyme_A` varchar(50) NOT NULL DEFAULT 'unspecified',
  `restriction_enzyme_B` varchar(50) NOT NULL DEFAULT 'unspecified',
  `reanneal_temp` varchar(15) NOT NULL DEFAULT 'unspecified',
  `separation_system` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sequence_confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`marker_assay_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marker_sequence_assignments`
--

DROP TABLE IF EXISTS `marker_sequence_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marker_sequence_assignments` (
  `marker_set` varchar(50) NOT NULL DEFAULT 'unspecified',
  `canonical_marker_name` varchar(15) NOT NULL DEFAULT '',
  `associated_sequence_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sequence_source_acronym` varchar(35) NOT NULL DEFAULT 'unspecified',
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified' COMMENT 'institution or organisation',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`canonical_marker_name`),
  KEY `canonical_marker_name` (`canonical_marker_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marker_sequence_hits`
--

DROP TABLE IF EXISTS `marker_sequence_hits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marker_sequence_hits` (
  `canonical_marker_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  `target_collection_id` varchar(20) NOT NULL DEFAULT 'unspecified',
  `hit_rank_number` varchar(15) NOT NULL DEFAULT 'unspecified',
  `target_hit_id` varchar(20) NOT NULL DEFAULT 'unspecified',
  `analysis_caried_out_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `marker_data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `target_collection_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`canonical_marker_name`,`target_collection_id`,`hit_rank_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marker_variations`
--

DROP TABLE IF EXISTS `marker_variations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marker_variations` (
  `marker_assay_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  `marker_variation` varchar(100) NOT NULL DEFAULT '',
  `description` longtext NOT NULL,
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_described` date NOT NULL DEFAULT '0000-00-00',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`marker_variation`),
  KEY `marker_assay` (`marker_assay_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `occasions`
--

DROP TABLE IF EXISTS `occasions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `occasions` (
  `occasion_id` varchar(30) NOT NULL DEFAULT '',
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `start_time` varchar(15) NOT NULL DEFAULT 'unspecified',
  `end_date` date NOT NULL DEFAULT '0000-00-00',
  `end_time` varchar(15) NOT NULL DEFAULT 'unspecified',
  `scored_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `recorded_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`occasion_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_accessions`
--

DROP TABLE IF EXISTS `plant_accessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_accessions` (
  `plant_line_name` varchar(50) NOT NULL DEFAULT 'unspecified',
  `plant_accession` varchar(70) NOT NULL DEFAULT '',
  `plant_accession_derivation` varchar(100) NOT NULL DEFAULT 'unspecified',
  `accession_originator` varchar(90) NOT NULL DEFAULT 'unspecified',
  `originating_organisation` varchar(90) NOT NULL DEFAULT 'unspecified',
  `ownership` varchar(100) NOT NULL DEFAULT 'unspecified',
  `year_produced` varchar(4) NOT NULL DEFAULT 'xxxx',
  `pollination_method` varchar(100) NOT NULL DEFAULT 'unspecified',
  `date_harvested` date NOT NULL DEFAULT '0000-00-00',
  `female_parent_plant_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `male_parent_plant_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `plant_accession_geolocation` geometry NOT NULL,
  `plant_accession_srid` int(11) NOT NULL,
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_accession`),
  KEY `plant_line` (`plant_line_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='MyISAM free: 16243712 kB';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_individuals`
--

DROP TABLE IF EXISTS `plant_individuals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_individuals` (
  `plant_accession` varchar(20) NOT NULL DEFAULT 'unspecified',
  `plant_individual_id` varchar(30) NOT NULL DEFAULT '',
  `seed_packet_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `plant_trial_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `row_plot_position_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `plant_sample_size` varchar(15) NOT NULL DEFAULT 'unspecified',
  `plant_number` varchar(15) NOT NULL DEFAULT 'unspecified',
  `date_planted` date NOT NULL DEFAULT '0000-00-00',
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_individual_id`),
  KEY `plant_accession` (`plant_accession`),
  KEY `individual` (`plant_individual_id`),
  KEY `trial` (`plant_trial_id`),
  KEY `row_plot_position` (`row_plot_position_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='MyISAM free: 14179328 kB; MyISAM free: 16243712 kB; (`plant_';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_line_assigned_genotypes`
--

DROP TABLE IF EXISTS `plant_line_assigned_genotypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_line_assigned_genotypes` (
  `plant_population` varchar(20) NOT NULL DEFAULT 'unspecified',
  `plant_line_name` varchar(50) NOT NULL DEFAULT 'unspecified',
  `mapping_locus` varchar(20) NOT NULL DEFAULT 'unspecified',
  `zygote_locus_genotype` varchar(15) NOT NULL DEFAULT 'unspecified',
  `assigned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_assigned` date NOT NULL DEFAULT '0000-00-00',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_line_name`,`mapping_locus`,`zygote_locus_genotype`) USING BTREE,
  KEY `mapping_locus` (`mapping_locus`),
  KEY `FK_plant_line_assigned_genotypes_1` (`plant_population`,`mapping_locus`,`zygote_locus_genotype`) USING BTREE,
  KEY `plant_line` (`plant_line_name`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_lines`
--

DROP TABLE IF EXISTS `plant_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_lines` (
  `plant_line_name` varchar(50) NOT NULL DEFAULT '',
  `genus` varchar(100) NOT NULL DEFAULT 'unspecified',
  `species` varchar(100) NOT NULL DEFAULT 'unspecified',
  `subtaxa` varchar(100) NOT NULL DEFAULT 'unspecified',
  `common_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_variety_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `named_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `organisation` varchar(100) NOT NULL DEFAULT 'unspecified',
  `genetic_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `previous_line_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_line_geolocation` geometry NOT NULL,
  `plant_line_srid` int(11) NOT NULL,
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_line_name`),
  KEY `plant_variety` (`plant_variety_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_marker_fragments`
--

DROP TABLE IF EXISTS `plant_marker_fragments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_marker_fragments` (
  `scoring_unit_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `marker_variation` varchar(100) NOT NULL DEFAULT 'unspecified',
  `occasion` varchar(100) NOT NULL DEFAULT 'unspecified',
  `fragment_number` varchar(15) NOT NULL DEFAULT 'unspecified',
  `total_number_fragments` varchar(15) NOT NULL DEFAULT 'unspecified',
  `calculated_value` varchar(15) NOT NULL DEFAULT 'unspecified',
  `units` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`scoring_unit_id`,`marker_variation`,`occasion`,`fragment_number`),
  KEY `marker_variation` (`marker_variation`),
  KEY `occasion` (`occasion`),
  KEY `fragment_number` (`fragment_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='MyISAM free: 16242688 kB; (`marker_variation`) REFER `cs_ful';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_marker_variations`
--

DROP TABLE IF EXISTS `plant_marker_variations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_marker_variations` (
  `scoring_unit_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `marker_variation` varchar(100) NOT NULL DEFAULT 'unspecified',
  `occasion` varchar(100) NOT NULL DEFAULT 'unspecified',
  `scored_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `lab_notebook_code` varchar(20) NOT NULL DEFAULT 'unspecified',
  `lab_notebook_page` char(3) NOT NULL DEFAULT 'xxx',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`scoring_unit_id`,`marker_variation`,`occasion`),
  KEY `marker_variation` (`marker_variation`),
  KEY `occasion` (`occasion`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_parts`
--

DROP TABLE IF EXISTS `plant_parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_parts` (
  `plant_part` varchar(100) NOT NULL DEFAULT '',
  `description` longtext NOT NULL,
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_part`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_population_lists`
--

DROP TABLE IF EXISTS `plant_population_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_population_lists` (
  `plant_population_id` varchar(20) NOT NULL DEFAULT 'unspecified',
  `plant_line_name` varchar(50) NOT NULL DEFAULT 'unspecified',
  `sort_order` varchar(15) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_population_id`,`plant_line_name`),
  KEY `plant_line` (`plant_line_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_populations`
--

DROP TABLE IF EXISTS `plant_populations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_populations` (
  `plant_population_id` varchar(20) NOT NULL DEFAULT '',
  `population_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `genus` varchar(100) NOT NULL DEFAULT 'unspecified',
  `species` varchar(100) NOT NULL DEFAULT 'unspecified',
  `female_parent_line` varchar(100) NOT NULL DEFAULT 'unspecified',
  `male_parent_line` varchar(100) NOT NULL DEFAULT 'unspecified',
  `canonical_population_name` varchar(20) DEFAULT 'unspecified',
  `description` longtext NOT NULL,
  `date_established` date NOT NULL DEFAULT '0000-00-00',
  `established_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `establishing_organisation` varchar(90) NOT NULL DEFAULT 'unspecified',
  `population_owned_by` varchar(90) DEFAULT 'unspecified',
  `comments` longtext,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_provenance` longtext NOT NULL,
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `plant_population_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  `assigned_population_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_population_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_scoring_units`
--

DROP TABLE IF EXISTS `plant_scoring_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_scoring_units` (
  `scoring_unit_id` varchar(50) NOT NULL DEFAULT '',
  `plant_trial_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `design_factor_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_accession` varchar(70) NOT NULL DEFAULT 'unspecified',
  `scored_plant_part` varchar(100) NOT NULL DEFAULT 'unspecified',
  `number_units_scored` varchar(15) NOT NULL DEFAULT 'unspecified',
  `scoring_unit_sample_size` varchar(15) NOT NULL DEFAULT 'unspecified',
  `scoring_unit_frame_size` varchar(15) NOT NULL DEFAULT 'unspecified',
  `date_planted` date NOT NULL DEFAULT '0000-00-00',
  `seed_packet_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `plant_scoring_unit_geolocation` geometry NOT NULL,
  `plant_scoring_unit_srid` int(11) NOT NULL,
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`scoring_unit_id`),
  KEY `trial` (`plant_accession`),
  KEY `row_plot_position` (`scored_plant_part`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='MyISAM free: 14179328 kB; MyISAM free: 16243712 kB; (`plant_';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_trial_collection_lists`
--

DROP TABLE IF EXISTS `plant_trial_collection_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_trial_collection_lists` (
  `plant_trial_collection_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `plant_trial_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_trial_collection_id`,`plant_trial_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_trial_collections`
--

DROP TABLE IF EXISTS `plant_trial_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_trial_collections` (
  `plant_trial_collection_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `project_description` longtext NOT NULL,
  `collection_description` longtext NOT NULL,
  `collected_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_trial_collection_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_trials`
--

DROP TABLE IF EXISTS `plant_trials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_trials` (
  `plant_trial_id` varchar(30) NOT NULL DEFAULT '',
  `project_descriptor` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_trial_description` longtext NOT NULL,
  `plant_population` varchar(20) NOT NULL DEFAULT 'unspecified',
  `trial_year` varchar(4) NOT NULL DEFAULT 'xxxx',
  `institute_id` varchar(90) NOT NULL DEFAULT 'unspecified',
  `trial_location_site_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `country` char(3) NOT NULL DEFAULT 'xxx',
  `place_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_trial_geolocation` geometry NOT NULL,
  `plant_trial_srid` int(11) NOT NULL,
  `latitude` varchar(15) NOT NULL DEFAULT 'unspecified',
  `longitude` varchar(15) NOT NULL DEFAULT 'unspecified',
  `altitude` varchar(15) NOT NULL DEFAULT 'unspecified',
  `terrain` varchar(100) NOT NULL DEFAULT 'unspecified',
  `soil_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `contact_person` varchar(90) NOT NULL DEFAULT 'unspecified',
  `design_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `statistical_factors` longtext NOT NULL,
  `design_factors` longtext NOT NULL,
  `design_layout_matrix` longtext NOT NULL,
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_trial_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_varieties`
--

DROP TABLE IF EXISTS `plant_varieties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_varieties` (
  `plant_variety_name` varchar(100) NOT NULL DEFAULT '',
  `genus` varchar(100) NOT NULL DEFAULT 'unspecified',
  `species` varchar(100) NOT NULL DEFAULT 'unspecified',
  `subtaxa` varchar(100) NOT NULL DEFAULT 'unspecified',
  `taxa_authority` varchar(100) NOT NULL DEFAULT 'unspecified',
  `subtaxa_authority` varchar(100) NOT NULL DEFAULT 'unspecified',
  `crop_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `plant_variety_geolocation` geometry NOT NULL,
  `plant_variety_srid` int(11) NOT NULL,
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_variety_name`),
  KEY `plant_variety_name` (`plant_variety_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='MyISAM free: 16242688 kB';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plant_variety_details`
--

DROP TABLE IF EXISTS `plant_variety_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plant_variety_details` (
  `plant_variety_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `data_attribution` varchar(100) NOT NULL DEFAULT 'unspecified',
  `country_of_origin` varchar(50) NOT NULL DEFAULT 'xxx',
  `country_registered` varchar(50) NOT NULL DEFAULT 'xxx',
  `year_registered` varchar(50) NOT NULL DEFAULT 'xxxx',
  `plant_variety_detail_geolocation` geometry NOT NULL,
  `plant_variety_detail_srid` int(11) NOT NULL,
  `breeder` varchar(90) NOT NULL DEFAULT 'unspecified',
  `breeders_variety_code` varchar(100) NOT NULL DEFAULT 'unspecified',
  `agent` varchar(90) NOT NULL DEFAULT 'unspecified',
  `owner` varchar(90) NOT NULL DEFAULT 'unspecified',
  `quoted_parentage` longtext NOT NULL,
  `female_parent` varchar(100) NOT NULL DEFAULT 'unspecified',
  `male_parent` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_provenance` longtext NOT NULL,
  PRIMARY KEY (`plant_variety_name`,`data_attribution`),
  KEY `plant_variety_name` (`plant_variety_name`),
  KEY `data_provenance` (`data_attribution`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pop_locus_genotype_alleles`
--

DROP TABLE IF EXISTS `pop_locus_genotype_alleles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pop_locus_genotype_alleles` (
  `plant_population` varchar(20) NOT NULL DEFAULT 'unspecified',
  `mapping_locus` varchar(20) NOT NULL DEFAULT 'unspecified',
  `locus_genotype` varchar(15) NOT NULL DEFAULT 'unspecified',
  `allele_number` varchar(15) NOT NULL DEFAULT 'unspecified',
  `gametic_locus_allele` varchar(20) NOT NULL DEFAULT 'unspecified',
  `allele_total` varchar(15) NOT NULL DEFAULT 'unspecified',
  `assigned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_assigned` date NOT NULL DEFAULT '0000-00-00',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`allele_number`,`locus_genotype`,`mapping_locus`,`plant_population`),
  KEY `plant_population` (`plant_population`),
  KEY `mapping_locus` (`mapping_locus`),
  KEY `locus_genotype` (`locus_genotype`),
  KEY `allele_number` (`allele_number`),
  KEY `FK_population_locus_genotype_alleles_2` (`plant_population`,`mapping_locus`,`locus_genotype`,`allele_number`),
  KEY `locus_allele` (`gametic_locus_allele`) USING BTREE,
  KEY `FK_population_locus_genotype_alleles_3` (`plant_population`,`mapping_locus`,`gametic_locus_allele`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pop_type_lookup`
--

DROP TABLE IF EXISTS `pop_type_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pop_type_lookup` (
  `population_type` varchar(100) NOT NULL DEFAULT '',
  `population_class` varchar(100) NOT NULL DEFAULT 'unspecified',
  `assigned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`population_type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `population_genotypes`
--

DROP TABLE IF EXISTS `population_genotypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `population_genotypes` (
  `plant_population` varchar(20) NOT NULL DEFAULT 'unspecified',
  `mapping_locus` varchar(20) NOT NULL DEFAULT 'unspecified',
  `zygote_locus_genotype` varchar(15) NOT NULL DEFAULT 'unspecified',
  `locus_code_system` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_population`,`mapping_locus`,`zygote_locus_genotype`) USING BTREE,
  KEY `plant_population` (`plant_population`),
  KEY `mapping_locus` (`mapping_locus`),
  KEY `genotype` (`zygote_locus_genotype`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `population_loci`
--

DROP TABLE IF EXISTS `population_loci`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `population_loci` (
  `plant_population` varchar(20) NOT NULL DEFAULT 'unspecified',
  `mapping_locus` varchar(20) NOT NULL DEFAULT 'unspecified',
  `marker_assay_name` varchar(20) NOT NULL DEFAULT 'unspecified',
  `defined_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`mapping_locus`,`plant_population`),
  KEY `plant_population` (`plant_population`),
  KEY `mapping_locus` (`mapping_locus`),
  KEY `marker_assay` (`marker_assay_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `population_locus_alleles`
--

DROP TABLE IF EXISTS `population_locus_alleles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `population_locus_alleles` (
  `plant_population` varchar(20) NOT NULL DEFAULT 'unspecified',
  `mapping_locus` varchar(20) NOT NULL DEFAULT 'unspecified',
  `gametic_locus_allele` varchar(20) NOT NULL DEFAULT 'unspecified',
  `marker_variation` varchar(100) NOT NULL DEFAULT 'unspecified',
  `allele_description` varchar(100) NOT NULL DEFAULT 'unspecified',
  `assigned_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_assigned` date NOT NULL DEFAULT '0000-00-00',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`plant_population`,`mapping_locus`,`gametic_locus_allele`) USING BTREE,
  KEY `plant_population` (`plant_population`),
  KEY `mapping_locus` (`mapping_locus`),
  KEY `marker_variation` (`marker_variation`),
  KEY `allele` (`gametic_locus_allele`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `primers`
--

DROP TABLE IF EXISTS `primers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `primers` (
  `primer` varchar(20) NOT NULL DEFAULT '',
  `sequence` varchar(200) NOT NULL DEFAULT 'unspecified',
  `sequence_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sequence_source_acronym` varchar(35) NOT NULL DEFAULT 'unspecified',
  `description` longtext NOT NULL,
  `design_seq_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `design_seq_source_acronym` varchar(35) NOT NULL DEFAULT 'unspecified',
  `reanneal_temp` varchar(15) NOT NULL DEFAULT 'unspecified',
  `designed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`primer`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `probes`
--

DROP TABLE IF EXISTS `probes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `probes` (
  `probe_name` varchar(20) NOT NULL DEFAULT '',
  `species` varchar(100) NOT NULL DEFAULT 'unspecified',
  `pcr_yes_or_no` enum('Y','N') NOT NULL DEFAULT 'N',
  `pcr_primer_name_a` varchar(20) NOT NULL DEFAULT 'unspecified',
  `pcr_primer_name_b` varchar(20) NOT NULL DEFAULT 'unspecified',
  `forward_position` varchar(100) NOT NULL DEFAULT 'unspecified',
  `reverse_position` varchar(100) NOT NULL DEFAULT 'unspecified',
  `template_source` varchar(100) NOT NULL DEFAULT 'unspecified',
  `clone_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `preparation_description` longtext NOT NULL,
  `prepared_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `probe_length` varchar(15) NOT NULL DEFAULT 'unspecified',
  `date_described` date NOT NULL DEFAULT '0000-00-00',
  `sequence_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `sequence_source_acronym` varchar(35) NOT NULL DEFAULT 'unspecified',
  `gene_description` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`probe_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proccessed_trait_datasets`
--

DROP TABLE IF EXISTS `proccessed_trait_datasets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proccessed_trait_datasets` (
  `proccessed_trait_dataset_id` varchar(50) NOT NULL DEFAULT '',
  `trial_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `trait_descriptor_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `population_id` varchar(20) NOT NULL DEFAULT 'unspecified',
  `raw_dataset_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `raw_dataset_analysis_occasion_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `processed_dataset_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `statistical_analysis_description` longtext NOT NULL,
  `trait_mean` varchar(15) NOT NULL DEFAULT 'unspecified',
  `trait_total_variance` varchar(15) NOT NULL DEFAULT 'unspecified',
  `trait_additive_genetic_variance` varchar(15) NOT NULL DEFAULT 'unspecified',
  `trait_percent_heritability` varchar(15) NOT NULL DEFAULT 'unspecified',
  `residual_variance` varchar(15) NOT NULL DEFAULT 'unspecified',
  `average_SED` varchar(15) NOT NULL DEFAULT 'unspecified',
  `line_mean_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`proccessed_trait_dataset_id`),
  KEY `trial_id` (`trial_id`,`trait_descriptor_id`,`population_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `processed_trait_datasets`
--

DROP TABLE IF EXISTS `processed_trait_datasets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `processed_trait_datasets` (
  `processed_trait_dataset_id` varchar(50) NOT NULL DEFAULT '',
  `trial_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `trait_descriptor_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `population_id` varchar(20) NOT NULL DEFAULT 'unspecified',
  `raw_dataset_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `raw_dataset_analysis_occasion` varchar(30) NOT NULL DEFAULT 'unspecified',
  `processed_dataset_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `stats_analysis_description` longtext NOT NULL,
  `trait_mean` varchar(15) NOT NULL DEFAULT 'unspecified',
  `trait_total_variance` varchar(15) NOT NULL DEFAULT 'unspecified',
  `additive_genetic_variance` varchar(15) NOT NULL DEFAULT 'unspecified',
  `trait_percent_heritability` varchar(15) NOT NULL DEFAULT 'unspecified',
  `residual_variance` varchar(15) NOT NULL DEFAULT 'unspecified',
  `average_SED` varchar(15) NOT NULL DEFAULT 'unspecified',
  `line_mean_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`processed_trait_dataset_id`),
  KEY `trial_id` (`trial_id`,`trait_descriptor_id`,`population_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qtl`
--

DROP TABLE IF EXISTS `qtl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qtl` (
  `qtl_job_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `processed_trait_dataset_id` varchar(100) NOT NULL DEFAULT 'unspecified',
  `linkage_group_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `qtl_rank` varchar(15) NOT NULL DEFAULT 'unspecified',
  `map_qtl_label` varchar(30) NOT NULL DEFAULT 'unspecified',
  `outer_interval_start` varchar(15) NOT NULL DEFAULT 'unspecified',
  `inner_interval_start` varchar(15) NOT NULL DEFAULT 'unspecified',
  `qtl_mid_position` varchar(15) NOT NULL DEFAULT 'unspecified',
  `inner_interval_end` varchar(15) NOT NULL DEFAULT 'unspecified',
  `outer_interval_end` varchar(15) NOT NULL DEFAULT 'unspecified',
  `peak_value` varchar(15) NOT NULL DEFAULT 'unspecified',
  `peak_P_value` varchar(15) NOT NULL DEFAULT 'unspecified',
  `regression_P` varchar(15) NOT NULL DEFAULT 'unspecified',
  `residual_P` varchar(15) NOT NULL DEFAULT 'unspecified',
  `additive_effect` varchar(15) NOT NULL DEFAULT 'unspecified',
  `se_additive_effect` varchar(15) NOT NULL DEFAULT 'unspecified',
  `genetic_variance_explained` varchar(15) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`qtl_job_id`,`processed_trait_dataset_id`,`linkage_group_id`,`qtl_rank`) USING BTREE,
  KEY `linkage_group` (`linkage_group_id`),
  KEY `trial` (`processed_trait_dataset_id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qtl_jobs`
--

DROP TABLE IF EXISTS `qtl_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qtl_jobs` (
  `qtl_job_id` varchar(100) NOT NULL DEFAULT '',
  `linkage_map_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `qtl_software` varchar(50) NOT NULL DEFAULT 'unspecified',
  `qtl_method` varchar(50) NOT NULL DEFAULT 'unspecified',
  `qtl_parameters` longtext NOT NULL,
  `threshold_specification_method` longtext NOT NULL,
  `threshold_significance_level` varchar(15) NOT NULL DEFAULT 'unspecified',
  `interval_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `inner_confidence_threshold` varchar(15) NOT NULL DEFAULT 'unspecified',
  `outer_confidence_threshold` varchar(15) NOT NULL DEFAULT 'unspecified',
  `qtl_statistic_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_run` date NOT NULL DEFAULT '0000-00-00',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`qtl_job_id`),
  KEY `qtl_software` (`qtl_software`,`qtl_method`),
  KEY `linkage_map_id` (`linkage_map_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restriction_enzymes`
--

DROP TABLE IF EXISTS `restriction_enzymes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `restriction_enzymes` (
  `restriction_enzyme` varchar(50) NOT NULL DEFAULT '',
  `recognition_site` varchar(30) NOT NULL DEFAULT 'unspecified',
  `data_provenance` longtext NOT NULL,
  PRIMARY KEY (`restriction_enzyme`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `row_plot_positions`
--

DROP TABLE IF EXISTS `row_plot_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `row_plot_positions` (
  `row_plot_position_id` varchar(30) NOT NULL DEFAULT '',
  `institute_id` varchar(90) NOT NULL DEFAULT 'unspecified',
  `field_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `block_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `row_plot_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `row_plot_position` varchar(20) NOT NULL DEFAULT 'unspecified',
  `plant_density` varchar(20) NOT NULL DEFAULT '',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`row_plot_position_id`),
  KEY `institute` (`institute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scoring_occasions`
--

DROP TABLE IF EXISTS `scoring_occasions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scoring_occasions` (
  `scoring_occasion_id` varchar(30) NOT NULL DEFAULT '',
  `score_start_date` date NOT NULL DEFAULT '0000-00-00',
  `score_end_date` date NOT NULL DEFAULT '0000-00-00',
  `scored_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `recorded_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`scoring_occasion_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trait_descriptors`
--

DROP TABLE IF EXISTS `trait_descriptors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trait_descriptors` (
  `trait_descriptor_id` varchar(30) NOT NULL DEFAULT '',
  `category` varchar(100) NOT NULL DEFAULT 'unspecified',
  `descriptor_name` varchar(100) NOT NULL DEFAULT 'unspecified',
  `units_of_measurements` varchar(100) NOT NULL DEFAULT 'unspecified',
  `where_to_score` longtext NOT NULL,
  `scoring_method` longtext NOT NULL,
  `when_to_score` varchar(100) NOT NULL DEFAULT 'unspecified',
  `stage_scored` varchar(100) NOT NULL DEFAULT 'unspecified',
  `precautions` longtext NOT NULL,
  `materials` longtext NOT NULL,
  `controls` longtext NOT NULL,
  `calibrated_against` longtext,
  `instrumentation_required` longtext NOT NULL,
  `likely_ambiguities` longtext NOT NULL,
  `contact_person` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_method_agreed` date NOT NULL DEFAULT '0000-00-00',
  `score_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `related_trait_ids` longtext,
  `related_characters` longtext,
  `possible_interactions` longtext NOT NULL,
  `authorities` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`trait_descriptor_id`),
  KEY `trait_descriptor_id` (`trait_descriptor_id`),
  KEY `category` (`category`),
  KEY `descriptor_name` (`descriptor_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trait_grades`
--

DROP TABLE IF EXISTS `trait_grades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trait_grades` (
  `trait_descriptor_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `trait_grade` varchar(100) NOT NULL DEFAULT 'unspecified',
  `description` longtext NOT NULL,
  `described_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`trait_descriptor_id`,`trait_grade`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trait_scores`
--

DROP TABLE IF EXISTS `trait_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trait_scores` (
  `scoring_unit_id` varchar(50) NOT NULL DEFAULT 'unspecified',
  `scoring_occasion_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `trait_descriptor_id` varchar(30) NOT NULL DEFAULT 'unspecified',
  `replicate_score_reading` varchar(15) NOT NULL DEFAULT 'unspecified',
  `score_value` varchar(100) DEFAULT NULL,
  `score_spread` varchar(50) NOT NULL DEFAULT 'unspecified',
  `value_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `spread_type` varchar(100) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  `entered_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `date_entered` date NOT NULL DEFAULT '0000-00-00',
  `data_provenance` longtext NOT NULL,
  `data_owned_by` varchar(90) NOT NULL DEFAULT 'unspecified',
  `data_status` varchar(100) NOT NULL DEFAULT 'unspecified',
  `confirmed_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  PRIMARY KEY (`scoring_unit_id`,`scoring_occasion_id`,`trait_descriptor_id`,`replicate_score_reading`),
  KEY `scoring_occasion` (`scoring_occasion_id`),
  KEY `trait_descriptor` (`trait_descriptor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='MyISAM free: 14179328 kB';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `version`
--

DROP TABLE IF EXISTS `version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `version` (
  `crop_group` varchar(25) NOT NULL DEFAULT 'unspecified crop',
  `data_version` varchar(20) NOT NULL DEFAULT 'v_1_01',
  `cs_version` varchar(25) NOT NULL DEFAULT 'unspecified version',
  `geolocation_system` varchar(25) NOT NULL,
  `last_updated` date NOT NULL DEFAULT '0000-00-00',
  `updated_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
  `comments` longtext NOT NULL,
  PRIMARY KEY (`data_version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-01-06  8:39:58
