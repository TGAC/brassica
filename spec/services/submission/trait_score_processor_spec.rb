require 'rails_helper'

RSpec.describe Submission::TraitScoreProcessor do
  let(:submission) { upload.submission }
  let(:basic_columns) {
    ["Plant scoring unit name", "Plant accession", "Originating organisation", "Year produced", "Plant line"]
  }

  context "mocked parser" do
    let(:upload) { build(:submission_upload, :trait_scores, file: nil) }
    let(:parser) { instance_double("Submission::TraitScoreParser", call: parser_result) }
    let(:parser_result) { Submission::TraitScoreParser::Result.new([], [], []) }

    subject { described_class.new(upload, parser) }

    context "when parser encounters errors" do
      it "adds errors to upload" do
        allow(parser_result).to receive(:errors).and_return([:no_trait_scores_sheet])
        subject.call
        expect(upload.errors[:file]).to match_array(["contents invalid. 'Trait scores' sheet missing."])
      end

      context "submission content was populated" do
        it 'resets submission content' do
          allow(parser_result).to receive(:errors).and_return([:no_trait_scores_sheet])

          upload.submission.content.update(:step04,
                                           trait_scores: { 'plant' => { 1 => '5' }},
                                           trait_mapping: { 0 => 0, 1 => 1 },
                                           replicate_numbers: {},
                                           design_factors: {},
                                           design_factor_names: [],
                                           accessions: {},
                                           lines_or_varieties: {}
                                          )

          subject.call
          expect(upload.submission.reload.content.trait_scores).to be_nil
          expect(upload.submission.content.trait_mapping).to be_nil
          expect(upload.submission.content.replicate_numbers).to be_nil
          expect(upload.submission.content.design_factors).to be_nil
          expect(upload.submission.content.design_factor_names).to be_nil
          expect(upload.submission.content.accessions).to be_nil
          expect(upload.submission.content.lines_or_varieties).to be_nil
        end
      end
    end

    it 'does nothing with empty input' do
      input_rows nil
      subject.call
      expect(subject.trait_scores).to eq({})
      expect(subject.trait_mapping).to eq({})
      expect(subject.design_factor_names).to eq([])
    end

    context 'provided with input of incomplete content' do
      it 'does nothing with no trait columns' do
        input_header basic_columns
        subject.call
        expect(subject.trait_mapping).to eq({})
      end

      it 'ignores all columns when no traits were chosen' do
        input_header basic_columns + ["first trait", "\"second,trait_name\""]
        subject.call
        expect(subject.trait_mapping).to eq({})
      end
    end

    describe "header processing" do
      before { input_rows [] }

      context 'provided with trait-rich submission' do
        it 'maps columns by name' do
          upload.submission.content.update(:step02, trait_descriptor_list: ['trait 1', 'trait 2'])

          input_header basic_columns + ["trait 2", "trait 1"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 1, 1 => 0)
        end

        it 'honors proper trait sorting by index' do
          upload.submission.content.update(:step02, trait_descriptor_list: ['Ctrait', 'Atrait', 'Btrait'])

          input_header basic_columns + ["Btrait", "Atrait", "Ctrait"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 2, 1 => 1, 2 => 0)
        end

        it 'uses natural ordering when no by-name mapping found' do
          upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])

          input_header basic_columns + ["trait 1", "trait 2"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 0, 1 => 1)
        end

        it 'works regardless traits are old or new' do
          td = create(:trait_descriptor, trait: create(:trait, name: 'old trait'))
          upload.submission.content.update(:step02, trait_descriptor_list: [td.id, 'new trait'])

          input_header basic_columns + ["new trait", "old trait"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 1, 1 => 0)
        end

        it 'reports error on repetitive mapping' do
          upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])

          input_header basic_columns + ["Xtrait", "Atrait"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 0, 1 => 0)
          expect(upload.errors[:file]).not_to be_empty
          expect(upload.errors[:file]).
            to eq ['Detected non unique column headers mapping to traits. Please check the column names.']
        end
      end

      context 'provided with submission with technical replicates' do
        before do
          upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
        end

        it 'correctly assigns well-named and ordered trait columns' do
          input_header basic_columns + ["Atrait rep1", "Atrait rep2", "Atrait rep3", "Btrait rep1", "Btrait rep2"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 0, 1 => 0, 2 => 0, 3 => 1, 4 => 1)
          expect(subject.replicate_numbers).to eq(0 => 1, 1 => 2, 2 => 3, 3 => 1, 4 => 2)
        end

        it 'correctly assigns well-named but misordered trait columns' do
          input_header basic_columns + ["Atrait rep1", "Btrait rep2", "Atrait rep3", "Atrait rep2", "Btrait rep1"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 0, 1 => 1, 2 => 0, 3 => 0, 4 => 1)
          expect(subject.replicate_numbers).to eq(0 => 1, 1 => 2, 2 => 3, 3 => 2, 4 => 1)
        end

        it 'correctly assigns, by index, misnamed trait columns' do
          input_header basic_columns +
            ["first rep1", "first rep2", "first rep3", "second rep1", "second rep2", "second rep3", "second rep4"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 0, 1 => 0, 2 => 0, 3 => 1, 4 => 1, 5 => 1, 6 => 1)
          expect(subject.replicate_numbers).to eq(0 => 1, 1 => 2, 2 => 3, 3 => 1, 4 => 2, 5 => 3, 6 => 4)
        end

        it 'tolerates traits with and without replicates' do
          input_header basic_columns + ["first rep1", "first rep2", "second"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 0, 1 => 0, 2 => 1)
          expect(subject.replicate_numbers).to eq(0 => 1, 1 => 2, 2 => 0)
        end

        it 'treats empty header as a no-replicate trait' do
          input_header basic_columns + ["first rep1", nil, "first rep2", "second"]

          subject.call
          expect(subject.trait_mapping).to eq(0 => 0, 1 => 1, 2 => 1, 3 => 2)
          expect(subject.replicate_numbers).to eq(0 => 1, 1 => 0, 2 => 2, 3 => 0)
        end

        it 'reports read replicate numbers in user log' do
          input_header basic_columns + ["first rep1", "first rep2"]

          subject.call
          expect(upload.logs).to include "   - Detected technical replicate number 1"
          expect(upload.logs).to include "   - Detected technical replicate number 2"
        end

        it 'does not report repetitive mapping' do
          input_header basic_columns + ["Atrait rep1", "Atrait rep2"]

          subject.call
          expect(upload.errors[:file]).to be_empty
        end
      end

      context 'provided with header containing design factors' do
        it 'records empty array for input with no design factors' do
          input_header basic_columns
          subject.call
          expect(subject.design_factor_names).to be_blank
        end

        it 'correctly records the array of design factor names' do
          input_header [basic_columns[0], "polytunnel", "rep", "sub_block", "pot_number"] + basic_columns[1..-1]
          subject.call
          expect(subject.design_factor_names).to eq ['polytunnel', 'rep', 'sub_block', 'pot_number']
        end

        it 'accepts empty design factors' do
          input_header [basic_columns[0], "", "rep", "", "pot_number"] + basic_columns[1..-1]
          subject.call
          expect(subject.design_factor_names).to eq ['', 'rep', '', 'pot_number']
        end
      end

      context 'for plant line or plant variety information' do
        it 'detects Plant line column' do
          input_header basic_columns
          subject.call
          expect(subject.instance_variable_get(:@line_or_variety)).to eq 'PlantLine'
        end

        it 'detects Plant variety column' do
          input_header basic_columns.tap { |columns| columns[-1] = "PlantVariety" }
          subject.call
          expect(subject.instance_variable_get(:@line_or_variety)).to eq 'PlantVariety'
        end

        it 'in unusual case of having both relations, prefer Plant line' do
          input_header basic_columns + ["Plant variety"]
          subject.call
          expect(subject.instance_variable_get(:@line_or_variety)).to eq 'PlantLine'
        end
      end
    end

    describe "data rows processing" do
      before do
        upload.submission.content.update(:step02, trait_descriptor_list: ['trait 1', 'trait 2'])
        input_header basic_columns + ["trait 1", "trait 2"]
      end

      it 'does not ignore no-score rows' do
        input_rows ["plant 1", "pa", "oo", "2017", "pl"], ["plant 2", "pa", "oo", "2017", "pl"]
        subject.call
        expect(subject.trait_scores).to eq('plant 1' => {}, 'plant 2' => {})
      end

      it 'records simple scores' do
        input_rows ["plant 1", "pa", "oo", "2017", "pl", "1"], ["plant 2", "pa", "oo", "2017", "pl", "2"]
        subject.call
        expect(subject.trait_scores).to eq('plant 1' => { 0 => '1' }, 'plant 2' => { 0 => '2' })
      end

      it 'records multiple sparse scores' do
        input_rows(
          ["plant 1", "pa", "oo", "2017", "pl", "1", "2"],
          ["plant 2", "pa", "oo", "2017", "pl", nil, "3"],
          ["plant 3", "pa", "oo", "2017", "pl", "4", nil]
        )

        subject.call
        expect(subject.trait_scores).
          to eq('plant 1' => { 0 => '1', 1 => '2' }, 'plant 2' => { 1 => '3' }, 'plant 3' => { 0 => '4' })
      end

      it 'requires each line to provide accession-related information' do
        input_rows(
          ["plant 1", "pa", "oo", "2017", "pl"],
          ["plant X", "pa", nil, nil, nil],
          ["plant 2", nil, nil, nil, nil],
          ["plant 3", "pa", "oo", nil, "pl"]
        )

        subject.call
        expect(subject.trait_scores).to eq('plant 1' => {})
        expect(upload.logs).
          to include 'Ignored row for plant X since Plant accession, Originating organisation and/or Year produced is missing.'
        expect(upload.logs).
          to include 'Ignored row for plant 2 since Plant accession, Originating organisation and/or Year produced is missing.'
        expect(upload.logs).
          to include 'Ignored row for plant 3 since Plant accession, Originating organisation and/or Year produced is missing.'
      end

      it 'parses accession information to a dedicated structure' do
        input_rows(
          ["plant 1", "pa", "oo", "2017", "pl"],
          ["plant X", "pa"],
          ["plant Y"],
          ["plant 2", "pa2", "oo", "2017", "pl"]
        )

        subject.call
        expect(subject.accessions).
          to eq('plant 1' => { plant_accession: 'pa', originating_organisation: 'oo', year_produced: '2017' },
                'plant 2' => { plant_accession: 'pa2', originating_organisation: 'oo', year_produced: '2017' })
      end

      it 'warns about ignored scores beyond number of trait columns' do
        input_rows ["plant 1", "pa", "oo", "2017", "pl", 1, 2, 3]
        subject.call
        expect(subject.trait_mapping).to eq(0 => 0, 1 => 1)
        expect(subject.trait_scores).to eq('plant 1' => { 0 => '1', 1 => '2' })
        expect(upload.logs).
          to include 'Encountered too many scoring values for plant 1. Ignoring value 3 in column 7.'
      end

      it 'parses Plant line name information' do
        input_rows ["plant 1", "pa", "oo", "2017", "pl"]
        subject.call
        expect(subject.lines_or_varieties).
          to eq('plant 1' => { relation_class_name: 'PlantLine', relation_record_name: 'pl' })
      end

      it 'parses Plant variety name information' do
        input_header basic_columns.tap { |columns| columns[-1] = "PlantVariety" }
        input_rows ["plant 1", "pa", "oo", "2017", "pv"]

        subject.call
        expect(subject.lines_or_varieties).
          to eq('plant 1' => { relation_class_name: 'PlantVariety', relation_record_name: 'pv' })
      end

      context 'depending on existence of plant accession' do
        before do
          create(:plant_accession, plant_accession: 'Old PA', originating_organisation: 'oo.org', year_produced: '2017')
        end

        it 'does not require PV/PL value for existing plant accessions' do
          input_rows ["plant 1", "Old PA", "oo.org", "2017"]
          subject.call
          expect(subject.trait_scores.size).to eq 1
          expect(subject.lines_or_varieties).
            to eq('plant 1' => { relation_class_name: 'PlantLine', relation_record_name: nil })
        end

        it 'ignores rows without PV/PL value for new plant accessions' do
          input_rows ["plant 1", "new_pa", "new_oo", "2017"]
          subject.call
          expect(subject.trait_scores.size).to eq 0
          expect(upload.logs).to include 'Ignored row for plant 1 since PlantLine value is missing.'
        end

        it 'stores encountered accessions for faster lookup' do
          expect(PlantAccession).to receive(:find_by).twice.and_call_original
          input_rows(
            ["plant 1", "Old PA", "oo.org", "2017"],
            ["plant n1", "new_pa", "new_oo", "2017"],
            ["plant n2", "new_pa", "new_oo", "2017"],
            ["plant 2", "Old PA", "oo.org", "2017"]
          )

          subject.call
          expect(subject.trait_scores.size).to eq 2
          expect(subject.lines_or_varieties).
            to eq('plant 1' => { relation_class_name: 'PlantLine', relation_record_name: nil },
                  'plant 2' => { relation_class_name: 'PlantLine', relation_record_name: nil })
        end
      end

      context 'provided with data containing design factors' do
        let(:design_factor_names) { ['polytunnel', 'rep', 'sub_block', 'pot_number'] }

        before do
          input_header [basic_columns[0]] + design_factor_names + basic_columns[1..-1] + ["trait 1", "trait 2"]
        end

        it 'records as many design factors as available' do
          input_rows ["plant 1", "1"], ["plant 2"], ["plant 3", "1", "2", "3", "4", "pa", "oo", "2017"]

          subject.call
          expect(subject.design_factors).
            to eq('plant 1' => ['1'], 'plant 2' => [], 'plant 3' => ['1', '2', '3', '4'])
        end

        it 'does not break when encountering empty lines' do
          input_rows ["plant 1", "1"], ["plant 3", "1"]
          subject.call
          expect(subject.design_factors).to eq('plant 1' => ['1'], 'plant 3' => ['1'])
        end

        it 'does not interfere with reading other information' do
          input_rows ["plant 1", "4", "4", "X", "4", "pa", "oo", "2017", "pl", "1", "2"]
          subject.call

          expect(subject.design_factors).to eq('plant 1' => ['4', '4', 'X', '4'])
          expect(subject.trait_scores).to eq('plant 1' => { 0 => '1', 1 => '2' })
          expect(subject.accessions).
            to eq('plant 1' => { plant_accession: 'pa', originating_organisation: 'oo', year_produced: '2017' })
          expect(subject.lines_or_varieties).
            to eq('plant 1' => { relation_class_name: 'PlantLine', relation_record_name: 'pl' })
        end
      end
    end

    def input_header(columns)
      allow(parser_result).to receive(:columns).and_return(columns)
    end

    def input_rows(*rows)
      allow(parser_result).to receive(:rows).and_return(rows.compact)
    end
  end

  context "default parser" do
    let(:file) { fixture_file("trait_scores.with_design_factors_and_replicates.xls", "application/vnd.ms-excel") }
    let(:upload) { create(:submission_upload, :trait_scores, file: file) }

    subject { described_class.new(upload) }

    it 'assigns content with parsed information' do
      subject.call

      expect(submission.content.to_h).to include(
        design_factor_names: ["room", "greenhouse"],
        design_factors: {
          "Plant 01" => ["1", "1"],
          "Plant 02" => ["2", "3"]
        },
        trait_mapping: { "0" => 0, "1" => 0, "2" => 1 },
        trait_scores: {
          "Plant 01" => { "0" => "12", "1" => "13", "2" => "33" },
          "Plant 02" => { "0" => "13", "2" => "24" }
        },
        replicate_numbers: { "0" => 1, "1" => 2, "2" => 0 },
        accessions: {
          "Plant 01" => { "plant_accession" => "acc1", "originating_organisation" => "BLOB", "year_produced" => "2000" },
          "Plant 02" => { "plant_accession" => "acc2", "originating_organisation" => "BLOB", "year_produced" => "2001" }
        },
        lines_or_varieties: {
          "Plant 01" => { "relation_class_name" => "PlantVariety", "relation_record_name" => "blobX" },
          "Plant 02" => { "relation_class_name" => "PlantVariety", "relation_record_name" => "blobY" }
        }
      )
    end

  end

  describe '#split_to_trait_and_replicate' do
    subject { described_class.new(nil) }

    it 'returns safe blanks for broken input' do
      expect(subject.send(:split_to_trait_and_replicate, nil)).to eq ['',0]
      expect(subject.send(:split_to_trait_and_replicate, '')).to eq ['',0]
    end

    it 'returns original input if no replicate was found' do
      expect(subject.send(:split_to_trait_and_replicate, 'a, trait name')).
        to eq ['a, trait name', 0]
      expect(subject.send(:split_to_trait_and_replicate, 'wrong_rep1 marker')).
        to eq ['wrong_rep1 marker', 0]
    end

    it 'detects replicate number and strips it off the trait name' do
      expect(subject.send(:split_to_trait_and_replicate, 'a trait namerep11')).
        to eq ['a trait name', 11]
      expect(subject.send(:split_to_trait_and_replicate, "trait with marker  rep0\t ")).
        to eq ["trait with marker", 0]
    end
  end
end
