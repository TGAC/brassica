require 'rails_helper'

RSpec.describe TrialScoringsController do
  let(:plant_trial) { create(:plant_trial, id: 11) }
  before(:each) { Rails.cache.clear }

  context '#show' do
    it 'does not render htmls on json format request' do
      get :show, format: :json, id: plant_trial.id
      expect(response).not_to render_template('plant_trials/show')
      expect(response).not_to render_template('layouts/application')
    end

    it 'returns datatables json on json format request' do
      get :show, format: :json, id: plant_trial.id
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 0
      expect(json['data']).to eq []
    end

    it 'calls scoring_table_data to get the actual data' do
      expect_any_instance_of(PlantTrial).to receive(:scoring_table_data).once.and_return([])
      get :show, format: :json, id: plant_trial.id
    end

    context 'with caching' do
      it 'caches the response' do
        expect_any_instance_of(PlantTrial).to receive(:scoring_table_data).once.and_return([])
        get :show, format: :json, id: plant_trial.id
        get :show, format: :json, id: plant_trial.id
      end

      it 'resets cache when new PSU data arrives' do
        get :show, format: :json, id: plant_trial.id
        expect_any_instance_of(PlantTrial).to receive(:scoring_table_data).once.and_return([])
        create(:plant_scoring_unit, plant_trial: plant_trial)
        get :show, format: :json, id: plant_trial.id
      end

      it 'resets cache when new TS data arrives' do
        psu = create(:plant_scoring_unit, plant_trial: plant_trial, updated_at: Time.now - 1.minute)
        get :show, format: :json, id: plant_trial.id
        expect_any_instance_of(PlantTrial).to receive(:scoring_table_data).once.and_return([])
        create(:trait_score, plant_scoring_unit: psu)
        get :show, format: :json, id: plant_trial.id
      end
    end

    context 'when called for zip format' do
      let(:tds) { create_list(:trait_descriptor, 2) }
      before(:each) {
        psus = [
          create(:plant_scoring_unit,
                 plant_accession: create(:plant_accession, plant_line: create(:plant_line, :with_variety)),
                 plant_trial: plant_trial,
                 scoring_unit_name: 'a'),
          create(:plant_scoring_unit,
                 plant_accession: create(:plant_accession, :with_variety),
                 plant_trial: plant_trial,
                 scoring_unit_name: 'b')
        ]
        create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: psus[0])
        create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: psus[0])
        create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: psus[1])
      }

      it 'produces a zip file' do
        get :show, format: :zip, id: plant_trial.id
        expect(response.content_type).to eq 'application/zip'
      end

      it 'compress three files in the zip file' do
        get :show, format: :zip, id: plant_trial.id
        file = Tempfile.new('plant_trial')
        file.write(response.body)
        file.close
        Zip::File.open(file.path) do |zfile|
          data = zfile.map do |entry|
            [entry.name, entry.get_input_stream.read]
          end
          expect(data.map(&:first)).
            to match_array %w(plant_trial.csv trait_descriptors.csv trait_scoring.csv)
          expect(data.map{ |d| d[1].lines.size }).to match_array [2,3,3]
        end
      end
    end
  end
end
