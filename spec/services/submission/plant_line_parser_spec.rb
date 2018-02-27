require 'rails_helper'

RSpec.describe Submission::PlantLineParser do
  let(:upload) { create(:upload, :plant_lines) }
  let(:submission) { upload.submission }
  subject { described_class.new(upload) }

  describe '#parse_header' do
    it 'reports all missing header' do
      input_is ''
      subject.send(:parse_header)
      expect(upload.errors[:file]).
        to eq ['No correct header provided.']
    end

    header = [
      'Species',
      'Plant variety',
      'Crop type',
      'Plant line',
      'Common name',
      'Previous line name',
      'Genetic status',
      'Sequence',
      'Plant accession',
      'Originating organisation',
      'Year produced'
    ]
    header.each do |column_name|
      it "reports missing #{column_name} column" do
        input_is header.reject{ |c| c == column_name }.join(',')
        subject.send(:parse_header)
        expect(upload.errors[:file]).
          to eq ["No correct header provided. Please provide the \"#{column_name}\" column."]
      end
    end

    it 'reports no error for a correct header' do
      input_is header.join(',')
      subject.send(:parse_header)
      expect(upload.errors[:file]).to eq []
    end
  end

  describe '#parse_plant_lines' do
    before(:each) { create(:taxonomy_term, name: 'Brassica napus') }

    it 'does nothing with empty input' do
      input_is ''
      subject.send(:parse_plant_lines)
      expect(subject.plant_line_names).to eq []
    end

    it 'saves new plant line information' do
      input_is 'Brassica napus,,,pl'
      subject.send(:parse_plant_lines)
      expect(subject.new_plant_lines).to eq [{
        plant_line_name: 'pl',
        plant_variety_name: nil,
        taxonomy_term: 'Brassica napus',
      }]
    end

    it 'handles optional new plant line information' do
      input_is 'Brassica napus,,,pl,cn,pln,gs,seq'
      subject.send(:parse_plant_lines)
      expect(subject.new_plant_lines[0][:common_name]).to eq 'cn'
      expect(subject.new_plant_lines[0][:previous_line_name]).to eq 'pln'
      expect(subject.new_plant_lines[0][:genetic_status]).to eq 'gs'
      expect(subject.new_plant_lines[0][:sequence_identifier]).to eq 'seq'
    end

    it 'handles empty newlines properly' do
      input_is "Brassica napus,,,pl1\n\nBrassica napus,,,pl2\n\n"
      subject.send(:parse_plant_lines)
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
      subject.send(:parse_plant_lines)
      expect(subject.plant_line_names).to eq []
      expect(upload.logs).
        to include 'Ignored row for pl since taxonomy unit called Brassica nullus was not found in BIP.'
    end

    it 'filters out duplicated new plant lines' do
      input_is "Brassica napus,,,pl\nBrassica napus,,,pl"
      subject.send(:parse_plant_lines)
      expect(subject.new_plant_lines.size).to eq 1
      expect(upload.logs).
        to include "Ignored row for pl since a plant line with that name is already defined in the uploaded file."
    end

    it 'allows use of existing plant' do
      create(:plant_line, plant_line_name: "pl")
      input_is ",,,pl"
      subject.send(:parse_plant_lines)
      expect(subject.new_plant_lines).to eq []
      expect(subject.plant_line_names).to eq ["pl"]
    end

    it 'allows use of existing plant line with correct data' do
      pl = create(:plant_line)
      pl_attrs = pl.attributes.slice("plant_line_name", "common_name", "previous_line_name", "genetic_status", "sequence_identifier")
      input_is "#{pl.taxonomy_term.name},,," + pl_attrs.values.join(",")
      subject.send(:parse_plant_lines)
      expect(subject.new_plant_lines).to eq []
      expect(subject.plant_line_names).to eq [pl.plant_line_name]
    end

    it 'blocks use of existing plant line with wrong species' do
      create(:taxonomy_term, name: "Brassica invalida")
      pl = create(:plant_line)
      input_is "Brassica invalida,,,#{pl.plant_line_name}"
      subject.send(:parse_plant_lines)
      expect(subject.plant_line_names).to eq []
      expect(upload.logs).
        to include "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP but uploaded data does not match existing record."
    end

    it 'blocks use of existing plant line with wrong plant line information' do
      pl = create(:plant_line)
      input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name},wrong-stuff"
      subject.send(:parse_plant_lines)
      expect(subject.plant_line_names).to eq []
      expect(upload.logs).
        to include "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP but uploaded data does not match existing record."
    end

    context "override of previously defined content" do
      it 'allows override of existing plant line with existing plant line' do
        pl = create(:plant_line)

        submission.content.update(:step03, plant_line_list: pl.plant_line_name)
        submission.save!

        input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name}"
        subject.send(:parse_plant_lines)
        expect(subject.plant_line_names).to eq [pl.plant_line_name]
        expect(subject.new_plant_lines).to eq []
      end

      it 'blocks override of new plant line with new plant line' do
        submission.content.update(:step03, plant_line_list: ["new-pl"],
                                           new_plant_lines: [{ plant_line_name: "new-pl",
                                                               plant_variety_name: "new-pv",
                                                               taxonomy_term: "Brassica napus" }])
        submission.save!

        input_is "Brassica napus,,,new-pl"
        subject.send(:parse_plant_lines)
        expect(submission.reload.content.plant_line_list).to eq ["new-pl"]
        expect(submission.content.new_plant_lines).
          to eq [{ "plant_line_name" => "new-pl", "plant_variety_name" => "new-pv", "taxonomy_term" => "Brassica napus" }]

        expect(upload.logs).
          to include "Ignored row for new-pl since a plant line with that name is already defined. "\
                     "Please clear the 'Plant line list' field before re-uploading a CSV file."
      end

      it 'blocks override of new plant line by existing plant line' do
        pl = create(:plant_line)

        submission.content.update(:step03, plant_line_list: [pl.plant_line_name],
                                           new_plant_lines: [{ plant_line_name: pl.plant_line_name,
                                                               taxonomy_term: "Brassica napus" }])
        submission.save!

        input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name}"
        subject.send(:parse_plant_lines)
        expect(submission.reload.content.plant_line_list).to eq [pl.plant_line_name]
        expect(submission.content.new_plant_lines).to eq [{ "plant_line_name" => pl.plant_line_name,
                                                            "taxonomy_term" => "Brassica napus" }]
        expect(upload.logs).
          to include "Ignored row for #{pl.plant_line_name} since a plant line with that name is already defined. "\
                     "Please clear the 'Plant line list' field before re-uploading a CSV file."
      end
    end

    context 'managing plant variety information' do
      it 'assigns existing plant variety to the new plant line' do
        pv = create(:plant_variety)
        input_is "Brassica napus,#{pv.plant_variety_name},,pl"
        subject.send(:parse_plant_lines)
        expect(subject.new_plant_lines[0][:plant_variety_name]).to eq pv.plant_variety_name
        expect(subject.new_plant_varieties).to eq({})
      end

      it 'saves new plant variety information with specified crop type' do
        input_is "Brassica napus,pv,ct,pl"
        subject.send(:parse_plant_lines)
        expect(subject.new_plant_lines[0][:plant_variety_name]).to eq 'pv'
        expect(subject.new_plant_varieties).
          to eq({ 'pl' => { plant_variety_name: 'pv', crop_type: 'ct' }})
      end

      it 'blocks use of existing plant line with wrong plant variety information' do
        pl = create(:plant_line, :with_variety)
        input_is "#{pl.taxonomy_term.name},wrong-pv-name,,#{pl.plant_line_name}"
        subject.send(:parse_plant_lines)
        expect(subject.plant_line_names).to eq []
        expect(upload.logs).
          to include "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP but uploaded data does not match existing record."
      end
    end

    context 'managing plant accession information' do
      ['pa', ',oo', ',,yp'].each do |incomplete_pa|
        it 'prevents creation of incomplete PA record' do
          input_is "Brassica napus,,,pl,,,,," + incomplete_pa
          subject.send(:parse_plant_lines)
          expect(upload.logs).to include
            "Ignored row for pl since incomplete plant accession was given."\
            "Either all or none of the Plant accession, Originating organisation and Year produced values must be provided."
        end
      end

      it 'allows use of existing plant accession with matching plant line' do
        pl = create(:plant_line)
        pa = create(:plant_accession, plant_line: pl)
        input_is "#{pl.taxonomy_term.name},,,#{pl.plant_line_name},,,,,#{pa.plant_accession},\"#{pa.originating_organisation}\",#{pa.year_produced}"
        subject.send(:parse_plant_lines)
        expect(subject.plant_line_names).to eq [pl.plant_line_name]
        expect(subject.new_plant_accessions).to be_empty
      end

      it 'blocks use of existing plant accession for new plant lines' do
        pa = create(:plant_accession)
        input_is "Brassica napus,,,wrong-pl-name,,,,,#{pa.plant_accession},\"#{pa.originating_organisation}\",#{pa.year_produced}"
        subject.send(:parse_plant_lines)
        expect(subject.plant_line_names).to eq []
        expect(upload.logs).to include "Ignored row for wrong-pl-name since it refers to a plant accession which currently exists in BIP and belongs to other plant line."
      end

      it 'detects repetition of plant accession information in the file' do
        input_is "Brassica napus,,,pl1,,,,,pa,oo,2017\nBrassica napus,,,pl2,,,,,pa,oo,2017"
        subject.send(:parse_plant_lines)
        expect(upload.logs).
          to include "Ignored row for pl2 since the defined plant accession was already used for another plant line in this file."
      end

      it 'saves new plant accession information for new plant lines' do
        input_is "Brassica napus,,,pl,,,,,pa,oo,2017"
        subject.send(:parse_plant_lines)
        expect(subject.new_plant_accessions).
          to eq('pl' => { plant_accession: 'pa', originating_organisation: 'oo', year_produced: '2017' })
      end
    end
  end

  describe '#call' do
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

  def input_is(string)
    allow(subject).to receive(:input).and_return(StringIO.new(string))
  end
end
