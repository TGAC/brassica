require 'rails_helper'

RSpec.describe Submission::PlantLineUploadProcessor do
  header_columns = [
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

  let(:upload) { create(:upload, :plant_lines) }

  it 'reports missing header row' do
    process("")
    expect(upload.errors[:file]).to eq ['No correct header provided.']
  end

  header_columns.each do |column_name|
    it "reports missing #{column_name} column" do
      process((header_columns - [column_name]).join(','))
      expect(upload.errors[:file]).
        to include("No correct header provided. Please provide the \"#{column_name}\" column.")
    end
  end

  it 'reports no error for a correct header' do
    process(header_columns.join(","))
    expect(upload.errors[:file]).to eq []
  end

  it 'does nothing with empty data' do
    processor = process(header_columns.join(","))
    expect(processor.plant_lines).to eq []
  end

  context "with plant line data present" do
    let(:header) { header_columns.join(",") }

    before { create(:taxonomy_term, name: 'Brassica napus') }

    it 'saves plant line information' do
      processor = process([header, 'Brassica napus,,,pl'].join("\n"))

      expect(processor.plant_lines).to eq [{
        plant_line_name: 'pl',
        plant_variety_name: '',
        taxonomy_term: 'Brassica napus',
        common_name: nil,
        previous_line_name: nil,
        genetic_status: nil,
        sequence_identifier: nil
      }]
    end

    it 'handles optional plant line information' do
      processor = process([header, 'Brassica napus,,,pl,cn,pln,gs,seq'].join("\n"))

      expect(processor.plant_lines[0][:common_name]).to eq 'cn'
      expect(processor.plant_lines[0][:previous_line_name]).to eq 'pln'
      expect(processor.plant_lines[0][:genetic_status]).to eq 'gs'
      expect(processor.plant_lines[0][:sequence_identifier]).to eq 'seq'
    end

    it 'handles empty newlines properly' do
      processor = process([header, "Brassica napus,,,pl1\n\nBrassica napus,,,pl2\n\n"].join("\n"))

      expect(processor.plant_lines).to eq [
        {
          plant_line_name: 'pl1',
          plant_variety_name: '',
          taxonomy_term: 'Brassica napus',
          common_name: nil,
          previous_line_name: nil,
          genetic_status: nil,
          sequence_identifier: nil
        },
        {
          plant_line_name: 'pl2',
          plant_variety_name: '',
          taxonomy_term: 'Brassica napus',
          common_name: nil,
          previous_line_name: nil,
          genetic_status: nil,
          sequence_identifier: nil
        }
      ]
    end

    it 'reports incorrect taxonomy term in species column' do
      processor = process([header, 'Brassica nullus,,,pl'].join("\n"))

      expect(processor.plant_lines).to eq []
      expect(upload.logs).
        to include 'Ignored row for pl since taxonomy unit called Brassica nullus was not found in BIP.'
    end

    it 'filters out duplicated plant lines' do
      processor = process([header, "Brassica napus,,,pl\nBrassica napus,,,pl"].join("\n"))

      expect(processor.plant_lines.size).to eq 1
      expect(upload.logs).
        to include "Ignored row for pl since a plant line with that name is already defined in the uploaded file."
    end

    it 'blocks recreating of already existing plant line' do
      pl = create(:plant_line)
      processor = process([header, "Brassica napus,,,#{pl.plant_line_name}"].join("\n"))

      expect(processor.plant_lines).to eq []
      expect(upload.logs).to include
        "Ignored row for #{pl.plant_line_name} since a plant line with that name is already present in BIP."\
        "Please use the 'Plant line list' field to add this existing plant line to the submitted population."
    end

    context 'managing plant variety information' do
      it 'assigns existing plant variety to the new plant line' do
        pv = create(:plant_variety)
        processor = process([header, "Brassica napus,#{pv.plant_variety_name},,pl"].join("\n"))

        expect(processor.plant_lines[0][:plant_variety_name]).to eq pv.plant_variety_name
        expect(processor.instance_variable_get(:@plant_varieties)).to eq({})
      end

      it 'saves new plant variety information with specified crop type' do
        processor = process([header, "Brassica napus,pv,ct,pl"].join("\n"))

        expect(processor.plant_lines[0][:plant_variety_name]).to eq 'pv'
        expect(processor.instance_variable_get(:@plant_varieties)).
          to eq({ 'pl' => { plant_variety_name: 'pv', crop_type: 'ct' }})
      end
    end

    context 'managing plant accession information' do
      ['pa', ',oo', ',,yp'].each do |incomplete_pa|
        it 'prevents creation of incomplete PA record' do
          process([header, "Brassica napus,,,pl,,,,," + incomplete_pa].join("\n"))

          expect(upload.logs).to include
            "Ignored row for pl since incomplete plant accession was given."\
            "Either all or none of the Plant accession, Originating organisation and Year produced values must be provided."
        end
      end

      it 'prevents reusing existing plant accession for new plant lines' do
        pa = create(:plant_accession)
        process([header, "Brassica napus,,,pl,,,,,#{pa.plant_accession},\"#{pa.originating_organisation}\",#{pa.year_produced}"].join("\n"))

        expect(upload.logs).to include
          "Ignored row for pl since it refers to a plant accession which currently exists in BIP."\
          "If your intention was to refer to an existing accession, please leave the Plant accession, Originating organisation and Year produced values blank for this plant line."
      end

      it 'detects repetition of plant accession information in the file' do
        process([header, "Brassica napus,,,pl1,,,,,pa,oo,2017\nBrassica napus,,,pl2,,,,,pa,oo,2017"].join("\n"))

        expect(upload.logs).
          to include "Ignored row for pl2 since the defined plant accession was already used for another plant line in this file."
      end

      it 'saves new plant accession information for new plant lines' do
        processor = process([header, "Brassica napus,,,pl,,,,,pa,oo,2017"].join("\n"))

        expect(processor.plant_accessions).
          to eq({ 'pl' => { plant_accession: 'pa', originating_organisation: 'oo', year_produced: '2017' }})
      end
    end
  end

  it 'assigns step03 content with parsed information' do
    create(:taxonomy_term, name: 'Brassica napus')
    create(:plant_variety, plant_variety_name: 'Valesca')
    create(:plant_accession, plant_accession: 'whri2004_C1', originating_organisation: 'WHRI', year_produced: '2004')

    process

    expect(upload.submission.content.step03.plant_line_list).to eq ['pl_ok_newpv_newpa', 'pl_ok_nopa']
    expect(upload.submission.content.step03.new_plant_lines).to eq [
      {
        'plant_line_name' => 'pl_ok_newpv_newpa',
        'plant_variety_name' => 'Alesi',
        'taxonomy_term' => 'Brassica napus',
        'common_name' => '',
        'previous_line_name' => '',
        'genetic_status' => '',
        'sequence_identifier' => ''
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

  def process(data = nil)
    described_class.new(upload, (StringIO.new(data) if data)).tap(&:call)
  end
end
