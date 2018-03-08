require 'rails_helper'

RSpec.describe Submission::PlantLineProcessor do
  let(:submission) { upload.submission }

  context "mocked parser" do
    let(:upload) { build(:submission_upload, :plant_lines, file: nil) }
    let(:parser) { instance_double("Submission::PlantLineParser", call: parser_result) }
    let(:parser_result) { Submission::PlantLineParser::Result.new([], []) }

    before { create(:taxonomy_term, name: 'Brassica napus') }

    subject { described_class.new(upload, parser) }

    context "when parser encounters errors" do
      it "adds errors to upload" do
        allow(parser_result).to receive(:errors).and_return([:no_plant_lines_sheet])
        subject.call
        expect(upload.errors[:file]).to match_array(["contents invalid. 'Plant lines' sheet missing."])
      end
    end

    it 'does nothing with empty input' do
      input_is ''
      subject.call
      expect(subject.plant_line_names).to eq []
    end

    it 'saves new plant line information' do
      input_is 'Brassica napus,,,pl'
      subject.call
      expect(subject.new_plant_lines).to eq [{
        plant_line_name: 'pl',
        plant_variety_name: nil,
        taxonomy_term: 'Brassica napus',
      }]
    end

    it 'handles optional new plant line information' do
      input_is 'Brassica napus,,,pl,cn,pln,gs,seq'
      subject.call
      expect(subject.new_plant_lines[0][:common_name]).to eq 'cn'
      expect(subject.new_plant_lines[0][:previous_line_name]).to eq 'pln'
      expect(subject.new_plant_lines[0][:genetic_status]).to eq 'gs'
      expect(subject.new_plant_lines[0][:sequence_identifier]).to eq 'seq'
    end

    it 'handles empty newlines properly' do
      input_is "Brassica napus,,,pl1", "Brassica napus,,,pl2"
      subject.call
      expect(subject.new_plant_lines).to eq [
        {
          plant_line_name: 'pl1',
          plant_variety_name: nil,
          taxonomy_term: 'Brassica napus',
        },
        {
          plant_line_name: 'pl2',
          plant_variety_name: nil,
          taxonomy_term: 'Brassica napus',
        }
      ]
    end

    it 'reports incorrect taxonomy term in species column' do
      input_is 'Brassica nullus,,,pl'
      subject.call
      expect(subject.plant_line_names).to eq []
      expect(upload.logs).
        to include 'Ignored row for pl since taxonomy unit called Brassica nullus was not found in BIP.'
    end

    it 'filters out duplicated new plant lines' do
      input_is "Brassica napus,,,pl", "Brassica napus,,,pl"
      subject.call
      expect(subject.new_plant_lines.size).to eq 1
      expect(upload.logs).
        to include "Ignored row for pl since a plant line with that name is already defined in the uploaded file."
    end

    it 'allows use of existing plant' do
      create(:plant_line, plant_line_name: "pl")
      input_is ",,,pl"
      subject.call
      expect(subject.new_plant_lines).to eq []
      expect(subject.plant_line_names).to eq ["pl"]
    end

    it 'allows use of existing plant line with correct data' do
      pl = create(:plant_line)
      pl_attrs = pl.attributes.slice("plant_line_name", "common_name", "previous_line_name", "genetic_status", "sequence_identifier")
      input_is "#{pl.taxonomy_term.name},,," + pl_attrs.values.join(",")
      subject.call
      expect(subject.new_plant_lines).to eq []
      expect(subject.plant_line_names).to eq [pl.plant_line_name]
    end

    it 'blocks use of existing plant line with wrong species' do
      create(:taxonomy_term, name: "Brassica invalida")
      pl = create(:plant_line)
      input_is "Brassica invalida,,,#{pl.plant_line_name}"
      subject.call
      expect(subject.plant_line_names).to eq []
      expect(upload.logs).
        to include "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP but uploaded data does not match existing record."
    end

    it 'blocks use of existing plant line with wrong plant line information' do
      pl = create(:plant_line)
      input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name},wrong-stuff"
      subject.call
      expect(subject.plant_line_names).to eq []
      expect(upload.logs).
        to include "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP but uploaded data does not match existing record."
    end

    context "override of previously defined content" do
      it 'allows override of existing plant line with existing plant line' do
        pl = create(:plant_line)

        submission.content.update(:step03, plant_line_list: [pl.plant_line_name])
        submission.save!

        input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name}"
        subject.call
        expect(submission.reload.content.plant_line_list).to eq [pl.plant_line_name]
        expect(submission.content.new_plant_varieties).to be_blank
        expect(submission.content.new_plant_accessions).to be_blank
      end

      it 'allows override of new plant line with new plant line' do
        submission.content.update(:step03,
          plant_line_list: ["new-pl"],
          new_plant_lines: [{ plant_line_name: "new-pl", plant_variety_name: "new-pv", taxonomy_term: "Brassica napus" }],
          new_plant_varieties: { "new-pl" => { "plant_variety_name" => "new-pv" } },
          new_plant_accessions: { "new-pl" => { "plant_accession" => "new-pa" } }
        )
        submission.save!

        input_is "Brassica napus,new-pv-2,,new-pl"
        subject.call
        expect(upload.errors).to be_blank
        expect(submission.reload.content.plant_line_list).to eq ["new-pl"]
        expect(submission.content.new_plant_lines).
          to eq [{ "plant_line_name" => "new-pl", "plant_variety_name" => "new-pv-2", "taxonomy_term" => "Brassica napus" }]

        expect(submission.content.new_plant_varieties).to eq("new-pl" => { "plant_variety_name" => "new-pv-2" })
        expect(submission.content.new_plant_accessions).to be_blank
      end

      it 'allows override of new plant line by existing plant line' do
        pl = create(:plant_line)

        submission.content.update(:step03,
          plant_line_list: [pl.plant_line_name],
          new_plant_lines: [{ plant_line_name: pl.plant_line_name, plant_variety_name: "new-pv", taxonomy_term: "Brassica napus" }],
          new_plant_varieties: { pl.plant_line_name => { "plant_variety_name" => "new-pv" } },
          new_plant_accessions: { pl.plant_line_name => { "plant_accession" => "new-pa" } }
        )
        submission.save!

        input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name}"
        subject.call
        expect(upload.errors).to be_blank
        expect(submission.reload.content.plant_line_list).to eq [pl.plant_line_name]
        expect(submission.content.new_plant_lines).to be_blank
        expect(submission.content.new_plant_varieties).to be_blank
        expect(submission.content.new_plant_accessions).to be_blank
      end
    end

    context 'managing plant variety information' do
      it 'assigns existing plant variety to the new plant line' do
        pv = create(:plant_variety)
        input_is "Brassica napus,#{pv.plant_variety_name},,pl"
        subject.call
        expect(subject.new_plant_lines[0][:plant_variety_name]).to eq pv.plant_variety_name
        expect(subject.new_plant_varieties).to eq({})
      end

      it 'saves new plant variety information with specified crop type' do
        input_is "Brassica napus,pv,ct,pl"
        subject.call
        expect(subject.new_plant_lines[0][:plant_variety_name]).to eq 'pv'
        expect(subject.new_plant_varieties).
          to eq({ 'pl' => { plant_variety_name: 'pv', crop_type: 'ct' }})
      end

      it 'blocks use of existing plant line with wrong plant variety information' do
        pl = create(:plant_line, :with_variety)
        input_is "#{pl.taxonomy_term.name},wrong-pv-name,,#{pl.plant_line_name}"
        subject.call
        expect(subject.plant_line_names).to eq []
        expect(upload.logs).
          to include "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP but uploaded data does not match existing record."
      end
    end

    context 'managing plant accession information' do
      ['pa', ',oo', ',,yp'].each do |incomplete_pa|
        it 'prevents creation of incomplete PA record' do
          input_is "Brassica napus,,,pl,,,,," + incomplete_pa
          subject.call
          expect(upload.logs).to include
            "Ignored row for pl since incomplete plant accession was given."\
            "Either all or none of the Plant accession, Originating organisation and Year produced values must be provided."
        end
      end

      it 'allows use of existing plant accession with matching plant line' do
        pl = create(:plant_line)
        pa = create(:plant_accession, plant_line: pl)
        input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name},,,,,#{pa.plant_accession},#{pa.originating_organisation},#{pa.year_produced}"
        subject.call
        expect(subject.plant_line_names).to eq [pl.plant_line_name]
        expect(subject.new_plant_accessions).to be_empty
      end

      it 'blocks use of existing plant accession for new plant lines' do
        pa = create(:plant_accession)
        input_is "Brassica napus,,,wrong-pl-name,,,,,#{pa.plant_accession},#{pa.originating_organisation},#{pa.year_produced}"
        subject.call
        expect(subject.plant_line_names).to eq []
        expect(upload.logs).to include "Ignored row for wrong-pl-name since it refers to a plant accession which currently exists in BIP and belongs to other plant line."
      end

      it 'detects repetition of plant accession information in the file' do
        input_is "Brassica napus,,,pl1,,,,,pa,oo,2017", "Brassica napus,,,pl2,,,,,pa,oo,2017"
        subject.call
        expect(upload.logs).
          to include "Ignored row for pl2 since the defined plant accession was already used for another plant line in this file."
      end

      it 'saves new plant accession information for new plant lines' do
        input_is "Brassica napus,,,pl,,,,,pa,oo,2017"
        subject.call
        expect(subject.new_plant_accessions).
          to eq('pl' => { plant_accession: 'pa', originating_organisation: 'oo', year_produced: '2017' })
      end
    end

    def input_is(*rows)
      rows = rows.map { |row| row.split(",").map(&:presence) }.map do |row|
        [
          { plant_variety_name: row[1], crop_type: row[2] }.compact,
          { plant_line_name: row[3], common_name: row[4], previous_line_name: row[5],
            genetic_status: row[6], sequence_identifier: row[7], taxonomy_term: row[0] }.compact,
          { plant_accession: row[8], originating_organisation: row[9], year_produced: row[10] }.compact
        ]
      end

      allow(parser_result).to receive(:rows).and_return(rows)
    end
  end

  context "default parser" do
    let(:upload) { create(:submission_upload, :plant_lines) }

    subject { described_class.new(upload) }

    before(:each) do
      tt = create(:taxonomy_term, name: 'Brassica napus')
      create(:plant_line, plant_line_name: "existing_pl")
      create(:plant_line, plant_line_name: "existing_pl_newpa", taxonomy_term: tt)
      create(:plant_variety, plant_variety_name: 'Valesca')
      create(:plant_accession, plant_accession: 'whri2004_C1', originating_organisation: 'WHRI', year_produced: '2004')
    end

    it 'assigns content with parsed information' do
      subject.call
      expect(submission.content.plant_line_list).
        to eq ['pl_ok_newpv_newpa', 'pl_ok_nopa', 'existing_pl', 'existing_pl_newpa']

      expect(submission.content.new_plant_lines).to eq [
        {
          'plant_line_name' => 'pl_ok_newpv_newpa',
          'plant_variety_name' => 'Alesi',
          'taxonomy_term' => 'Brassica napus',
        },
        {
          'plant_line_name' => 'pl_ok_nopa',
          'plant_variety_name' => 'Valesca',
          'taxonomy_term' => 'Brassica napus',
          'common_name' => 'Correct plant line',
          'previous_line_name' => 'pl_ok_old',
          'genetic_status' => 'inbred',
          'sequence_identifier' => 'SRR3134398'
        }
      ]
      expect(submission.content.new_plant_varieties).to eq({
        'pl_ok_newpv_newpa' => {
          'plant_variety_name' => 'Alesi',
          'crop_type' => 'Winter oilseed rape'
        }
      })
      expect(submission.content.new_plant_accessions).to eq({
        'pl_ok_newpv_newpa' => {
          'plant_accession' => 'New accession X',
          'originating_organisation' => 'EI',
          'year_produced' => '2017'
        },
        'existing_pl_newpa' => {
          'plant_accession' => 'New accession Y',
          'originating_organisation' => 'EI',
          'year_produced' => '2018'
        }
      })
    end
  end
end
