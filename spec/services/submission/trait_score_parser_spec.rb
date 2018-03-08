require 'rails_helper'

RSpec.describe Submission::TraitScoreParser do
  subject { described_class.new.call(filepath) }

  context "with empty xls" do
    let(:filepath) { fixture_file_path("xls/empty.xls") }

    it "returns invalid result" do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:no_trait_scores_sheet)
    end
  end

  context "with missing header columns" do
    let(:filepath) { fixture_file_path("trait_scores.missing_header_columns.xls") }

    it "reports errors" do
      expect(subject).not_to be_valid
      expect(subject.errors).to eq([
        :no_line_or_variety_header,
        :no_plant_scoring_unit_name_header,
        :no_plant_accession_header,
        :no_originating_organisation_header,
        :no_year_produced_header
      ])
    end
  end

  context "with missing header rows" do
    let(:filepath) { fixture_file_path("trait_scores.missing_header_rows.xls") }

    it "reports error" do
      expect(subject).not_to be_valid
      expect(subject.errors).to eq([:invalid_trait_scores_header])
    end
  end

  context "with empty template" do
    let(:filepath) { fixture_file_path("trait_scores.empty.xls") }

    it 'returns data rows' do
      expect(subject).to be_valid
      expect(subject.rows).to eq []
    end
  end

  context "with correct xls (no design factors or replicates)" do
    let(:filepath) { fixture_file_path("trait_scores.xls") }

    it 'returns data rows' do
      expect(subject).to be_valid
      expect(subject.columns).to eq ["Plant scoring unit name", "Plant accession", "Originating organisation",
                                     "Year produced", "Plant line", "oleic acid content", "seed mature time"]
      expect(subject.rows).to match_array [
        ["assay_df_hzau_1809", "accession1", "HZAU", "2004", nil, "56.98", "249.00"],
        ["assay_df_hzau_1805", "accession1", "HZAU", "2004", nil, "19.17", "252.00"],
        ["assay_df_hzau_1698", "accession2", "HZAU", "2004", nil, "18.48", "255.00"],
        ["assay_df_hzau_1693", "accession2", "HZAU", "2004", nil, "58.50", nil],
        ["assay_df_hzau_1692", "accession2", "HZAU", "2004", nil, "29.09", "254.00"],
        ["assay_df_hzau_1493", "accession2", "HZAU", "2004", nil, nil, "215.00"],
        ["assay_df_hzau_1492", "accession2", "HZAU", "2004", nil, nil, nil],
        ["assay_df_hzau_1803", "accession2", "HZAU", "2004", nil, "56.75", "253.00"]
      ]
    end
  end

  context "with correct xls (with design factors and replicates)" do
    let(:filepath) { fixture_file_path("trait_scores.with_design_factors_and_replicates.xls") }

    it 'returns data rows' do
      expect(subject).to be_valid
      expect(subject.columns).to eq ["Plant scoring unit name",
                                     "room", "greenhouse",
                                     "Plant accession", "Originating organisation", "Year produced",
                                     "Plant variety",
                                     "glucosinolate content rep1", "glucosinolate content rep2",
                                     "2,4-dichlorophenoxyacetic acid sensitivity"]

      expect(subject.rows).to match_array [
        ["Plant 01", "1", "1", "acc1", "BLOB", "2000", "blobX", "12", "13", "33"],
        ["Plant 02", "2", "3", "acc2", "BLOB", "2001", "blobY", "13", nil, "24"]
      ]
    end
  end
end
