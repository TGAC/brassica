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
  end
end
