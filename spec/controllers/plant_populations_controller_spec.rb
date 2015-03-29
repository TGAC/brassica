require 'rails_helper'

RSpec.describe PlantPopulationsController do
  context '#index' do
    it 'returns table template on html format request' do
      get :index
      expect(response).to render_template('plant_populations/index')
      expect(response).to render_template('layouts/application')
    end

    it 'does not render htmls on json format request' do
      get :index, format: :json
      expect(response).not_to render_template('plant_populations/index')
      expect(response).not_to render_template('layouts/application')
    end

    it 'returns datatables json on json format request' do
      pps = create_list(:plant_population, 2)
      get :index, format: :json
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 2
      expect(json['data'].size).to eq 2
      expect(json['data'].map(&:first)).to match_array pps.map(&:id)
    end

    it 'supports query filtering on json format request' do
      pps = create_list(:plant_population, 2).map(&:plant_population_id)
      get :index, format: :json, query: { plant_population_id: pps[0] }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 1
      expect(json['data'].size).to eq 1
      expect(json['data'][0][0]).to eq pps[0]
    end
  end
end
