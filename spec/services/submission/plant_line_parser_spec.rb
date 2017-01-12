require 'rails_helper'

RSpec.describe Submission::PlantLineParser do
  let(:upload) { create(:upload, :plant_lines) }
  subject { described_class.new(upload) }

  describe '#parse_header' do
    it 'reports all missing header' do
      input_is ''
      subject.send(:parse_header)
      expect(upload.errors[:file]).
        to eq ['No correct header provided.']
    end

    header = ['Species','Plant variety','Crop type','Plant line','Plant accession','Originating organisation','Year produced']
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
      expect(subject.plant_lines).to eq []
    end

    it 'saves plant line information' do
      input_is 'Brassica napus,,,pl'
      subject.send(:parse_plant_lines)
      expect(subject.plant_lines).to eq [{
        plant_line_name: 'pl',
        plant_variety_name: '',
        taxonomy_term: 'Brassica napus'
      }]
    end

    it 'handles empty newlines properly' do
      input_is "Brassica napus,,,pl1\n\nBrassica napus,,,pl2\n\n"
      subject.send(:parse_plant_lines)
      expect(subject.plant_lines).to eq [
        { plant_line_name: 'pl1', plant_variety_name: '', taxonomy_term: 'Brassica napus' },
        { plant_line_name: 'pl2', plant_variety_name: '', taxonomy_term: 'Brassica napus' }
      ]
    end

    it 'reports incorrect taxonomy term in species column' do
      input_is 'Brassica nullus,,,pl'
      subject.send(:parse_plant_lines)
      expect(subject.plant_lines).to eq []
      expect(upload.logs).
        to include 'Ignored row for pl since taxonomy unit called Brassica nullus was not found in BIP.'
    end

    it 'filters out duplicated plant lines' do
      input_is "Brassica napus,,,pl\nBrassica napus,,,pl"
      subject.send(:parse_plant_lines)
      expect(subject.plant_lines.size).to eq 1
      expect(upload.logs).
        to include "Ignored row for pl since a plant line with that name is already defined in the uploaded file."
    end

    it 'blocks recreating of already existing plant line' do
      pl = create(:plant_line)
      input_is "Brassica napus,,,#{pl.plant_line_name}"
      subject.send(:parse_plant_lines)
      expect(subject.plant_lines).to eq []
      expect(upload.logs).to include
        "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP."\
        "Please use the 'Plant line list' field to add this existing plant line to the submitted population."
    end

    context 'managing plant variety information' do
      it 'assigns existing plant variety to the new plant line' do
        pv = create(:plant_variety)
        input_is "Brassica napus,#{pv.plant_variety_name},,pl"
        subject.send(:parse_plant_lines)
        expect(subject.plant_lines[0][:plant_variety_name]).to eq pv.plant_variety_name
        expect(subject.instance_variable_get(:@plant_varieties)).to eq({})
      end

      it 'saves new plant variety information with specified crop type' do
        input_is "Brassica napus,pv,ct,pl"
        subject.send(:parse_plant_lines)
        expect(subject.plant_lines[0][:plant_variety_name]).to eq 'pv'
        expect(subject.instance_variable_get(:@plant_varieties)).
          to eq({ 'pl' => { plant_variety_name: 'pv', crop_type: 'ct' }})
      end
    end

    context 'managing plant accession information' do
      ['pa', ',oo', ',,yp'].each do |incomplete_pa|
        it 'prevents creation of incomplete PA record' do
          input_is "Brassica napus,,,pl," + incomplete_pa
          subject.send(:parse_plant_lines)
          expect(upload.logs).to include
            "Ignored row for pl since incomplete plant accession was given."\
            "Either all or none of the Plant accession, Originating organisation and Year produced values must be provided."
        end
      end

      it 'prevents reusing existing plant accession for new plant lines' do
        pa = create(:plant_accession)
        input_is "Brassica napus,,,pl,#{pa.plant_accession},\"#{pa.originating_organisation}\",#{pa.year_produced}"
        subject.send(:parse_plant_lines)
        expect(upload.logs).to include
          "Ignored row for pl since it refers to a plant accession which currently exists in BIP."\
          "If your intention was to refer to an existing accession, please leave the Plant accession, Originating organisation and Year produced values blank for this plant line."
      end

      it 'detects repetition of plant accession information in the file' do
        input_is "Brassica napus,,,pl1,pa,oo,2017\nBrassica napus,,,pl2,pa,oo,2017"
        subject.send(:parse_plant_lines)
        expect(upload.logs).
          to include "Ignored row for pl2 since the defined plant accession was already used for another plant line in this file."
      end

      it 'saves new plant accession information for new plant lines' do
        input_is "Brassica napus,,,pl,pa,oo,2017"
        subject.send(:parse_plant_lines)
        expect(subject.instance_variable_get(:@plant_accessions)).
          to eq({ 'pl' => { plant_accession: 'pa', originating_organisation: 'oo', year_produced: '2017' }})
      end
    end
  end

  describe '#call' do
    before(:each) do
      create(:taxonomy_term, name: 'Brassica napus')
      create(:plant_variety, plant_variety_name: 'Valesca')
      create(:plant_accession, plant_accession: 'whri2004_C1', originating_organisation: 'WHRI', year_produced: '2004')
    end

    it 'assigns step03 content with parsed information' do
      subject.call
      expect(upload.submission.content.step03.plant_line_list).to eq ['pl_ok_newpv_newpa', 'pl_ok_nopa']
      expect(upload.submission.content.step03.new_plant_lines).to eq [
        {
          'plant_line_name' => 'pl_ok_newpv_newpa',
          'plant_variety_name' => 'Alesi',
          'taxonomy_term' => 'Brassica napus'
        },
        {
          'plant_line_name' => 'pl_ok_nopa',
          'plant_variety_name' => 'Valesca',
          'taxonomy_term' => 'Brassica napus'
        }
      ]
      expect(upload.submission.content.step03.new_plant_varieties).to eq({
        'pl_ok_newpv_newpa' => {
          'plant_variety_name' => 'Alesi',
          'crop_type' => 'Winter oilseed rape'
        }
      })
      expect(upload.submission.content.step03.new_plant_accessions).to eq({
        'pl_ok_newpv_newpa' => {
          'plant_accession' => 'New accession X',
          'originating_organisation' => 'EI',
          'year_produced' => '2017'
        }
      })
    end
  end

  def input_is(string)
    allow(subject).to receive(:input).and_return(StringIO.new(string))
  end
end
