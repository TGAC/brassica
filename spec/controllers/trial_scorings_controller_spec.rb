require 'rails_helper'

RSpec.describe TrialScoringsController do
  let(:plant_trial) { create(:plant_trial) }

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

    it 'passes empty array to scoring_table_data if no TDs are given in params' do
      expect_any_instance_of(PlantTrial).to receive(:scoring_table_data).with([]).once.and_return([])
      get :show, format: :json, id: plant_trial.id
    end
  end
end
