require 'rails_helper'

RSpec.describe PlantPopulationsController do
  context '#index' do
    it 'returns table template on html request' do
      get :index
      expect(response).to render_template('plant_populations/index')
      expect(response).to render_template('layouts/application')
    end

    it 'does not render htmls on ajax request' do
      get :index, format: :json
      expect(response).not_to render_template('plant_populations/index')
      expect(response).not_to render_template('layouts/application')
    end

    it 'returns datatables json on ajax request' do
      pps = create_list(:plant_population, 2)
      get :index, format: :json
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 2
      expect(json['data'].size).to eq 2
      expect(json['data'].map(&:first)).to match_array pps.map(&:id)
    end
  end
end
