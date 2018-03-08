require 'rails_helper'

RSpec.describe Submission::PlantLineParser do
  subject { described_class.new.call(filepath) }

  context "with empty xls" do
    let(:filepath) { fixture_file_path("xls/empty.xls") }

    it "returns invalid result" do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:no_plant_lines_sheet)
    end
  end

  context "with missing header columns" do
    let(:filepath) { fixture_file_path("plant_lines.missing_header_columns.xls") }

    it "reports errors" do
      expect(subject).not_to be_valid
      expect(subject.errors).to eq([
        :no_species_header,
        :no_plant_variety_header,
        :no_crop_type_header,
        :no_plant_line_header,
        :no_common_name_header,
        :no_previous_line_name_header,
        :no_genetic_status_header,
        :no_sequence_header,
        :no_plant_accession_header,
        :no_originating_organisation_header,
        :no_year_produced_header
      ])
    end
  end

  context "with missing header rows" do
    let(:filepath) { fixture_file_path("plant_lines.missing_header_rows.xls") }

    it "reports error" do
      expect(subject).not_to be_valid
      expect(subject.errors).to eq([:invalid_plant_lines_header])
    end
  end

  context "with correct xls" do
    let(:filepath) { fixture_file_path("plant_lines.xls") }

    it 'returns data rows' do
      expect(subject).to be_valid
      expect(subject.rows).to eq([
        [
          { plant_variety_name: "Alesi", crop_type: "Winter oilseed rape" },
          { plant_line_name: "pl_ok_newpv_newpa", taxonomy_term: "Brassica napus" },
          { plant_accession: "New accession X", originating_organisation: "EI", year_produced: "2017" }
        ],
        [
          { plant_variety_name: "Valesca", crop_type: "Winter oilseed rape" },
          { plant_line_name: "pl_wrong_repeated_pa", taxonomy_term: "Brassica napus" },
          { plant_accession: "New accession X", originating_organisation: "EI", year_produced: "2017" }
        ],
        [
          { plant_variety_name: "Valesca", crop_type: "Winter oilseed rape" },
          { plant_line_name: "pl_ok_nopa", common_name: "Correct plant line", previous_line_name: "pl_ok_old",
            genetic_status: "inbred", sequence_identifier: "SRR3134398", taxonomy_term: "Brassica napus" },
          {}
        ],
        [
          { plant_variety_name: "Valesca", crop_type: "Winter oilseed rape" },
          { plant_line_name: "pl_wrong_partial_pa", taxonomy_term: "Brassica napus" },
          { originating_organisation: "My org", year_produced: "2014" }
        ],
        [
          { plant_variety_name: "Valesca", crop_type: "Winter oilseed rape" },
          { plant_line_name: "pl_wrong_existing_pa", taxonomy_term: "Brassica napus" },
          { plant_accession: "whri2004_C1", originating_organisation: "WHRI", year_produced: "2004" }
        ],
        [
          {}, { plant_line_name: "existing_pl" }, {}
        ],
        [
          {},
          { plant_line_name: "existing_pl_newpa" },
          { plant_accession: "New accession Y", originating_organisation: "EI", year_produced: "2018" }
        ]
      ])
    end
  end
end
