RENAME TABLE plant_variety_detail to plant_variety_details;

ALTER TABLE plant_accessions
  ADD COLUMN plant_accession_geolocation geometry NOT NULL AFTER male_parent_plant_id;

ALTER TABLE plant_accessions
  ADD COLUMN plant_accession_srid INT(11) NOT NULL AFTER plant_accession_geolocation;

ALTER TABLE plant_trials
  ADD COLUMN plant_trial_geolocation geometry NOT NULL AFTER place_name; 

ALTER TABLE plant_trials
  ADD COLUMN plant_trial_srid INT(11) NOT NULL AFTER plant_trial_geolocation;

ALTER TABLE plant_scoring_units
  ADD COLUMN plant_scoring_unit_geolocation geometry NOT NULL AFTER seed_packet_id;

ALTER TABLE plant_scoring_units
  ADD COLUMN plant_scoring_unit_srid INT(11) NOT NULL AFTER plant_scoring_unit_geolocation;

ALTER TABLE plant_varieties
  ADD COLUMN plant_variety_geolocation geometry NOT NULL AFTER crop_type;

ALTER TABLE plant_varieties
  ADD COLUMN plant_variety_srid INT(11) NOT NULL AFTER plant_variety_geolocation;

ALTER TABLE plant_variety_details   
  ADD COLUMN plant_variety_detail_geolocation geometry NOT NULL AFTER year_registered;

ALTER TABLE plant_variety_details
  ADD COLUMN plant_variety_detail_srid INT(11) NOT NULL AFTER plant_variety_detail_geolocation;

ALTER TABLE plant_lines
  ADD COLUMN plant_line_geolocation geometry NOT NULL AFTER previous_line_name;

ALTER TABLE plant_lines
  ADD COLUMN plant_line_srid INT(11) NOT NULL AFTER plant_line_geolocation;


DROP TABLE IF EXISTS `version`;

CREATE TABLE `version` (
`crop_group` varchar(25) NOT NULL DEFAULT 'unspecified crop',
`data_version` varchar(20) NOT NULL DEFAULT 'v_1_01',
`cs_version` varchar(25) NOT NULL DEFAULT 'unspecified version',
`geolocation_system` varchar(25) NOT NULL DEFAULT 'unspecified system',
`last_updated` date NOT NULL DEFAULT '0000-00-00',
`updated_by_whom` varchar(90) NOT NULL DEFAULT 'unspecified',
`comments` longtext NOT NULL,
 PRIMARY KEY (`data_version`)
);
 


