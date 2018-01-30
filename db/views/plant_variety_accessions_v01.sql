(
  SELECT
    plant_accessions.id,
    plant_accessions.plant_accession,
    plant_accessions.plant_accession_derivation,
    plant_accessions.accession_originator,
    plant_accessions.originating_organisation,
    plant_accessions.year_produced,
    plant_accessions.date_harvested,
    plant_accessions.female_parent_plant_id,
    plant_accessions.male_parent_plant_id,
    plant_accessions.comments,
    plant_accessions.entered_by_whom,
    plant_accessions.date_entered,
    plant_accessions.data_provenance,
    plant_accessions.data_owned_by,
    plant_accessions.confirmed_by_whom,
    plant_accessions.plant_line_id,
    plant_accessions.plant_scoring_units_count,
    plant_accessions.created_at,
    plant_accessions.updated_at,
    plant_accessions.user_id,
    plant_accessions.published,
    plant_accessions.published_on,
    plant_accessions.plant_variety_id
  FROM plant_accessions
  WHERE plant_accessions.plant_variety_id IS NOT NULL
)
UNION
(
  SELECT
    plant_accessions.id,
    plant_accessions.plant_accession,
    plant_accessions.plant_accession_derivation,
    plant_accessions.accession_originator,
    plant_accessions.originating_organisation,
    plant_accessions.year_produced,
    plant_accessions.date_harvested,
    plant_accessions.female_parent_plant_id,
    plant_accessions.male_parent_plant_id,
    plant_accessions.comments,
    plant_accessions.entered_by_whom,
    plant_accessions.date_entered,
    plant_accessions.data_provenance,
    plant_accessions.data_owned_by,
    plant_accessions.confirmed_by_whom,
    plant_accessions.plant_line_id,
    plant_accessions.plant_scoring_units_count,
    plant_accessions.created_at,
    plant_accessions.updated_at,
    plant_accessions.user_id,
    plant_accessions.published,
    plant_accessions.published_on,
    plant_lines.plant_variety_id
  FROM plant_accessions LEFT OUTER JOIN plant_lines
  ON plant_accessions.plant_line_id = plant_lines.id
  WHERE plant_accessions.plant_variety_id IS NULL
);
