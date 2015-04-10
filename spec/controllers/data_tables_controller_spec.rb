require 'rails_helper'

RSpec.describe DataTablesController do
  context '#index' do
    it 'requires model param to work' do
      expect{ get(:index) }.
        to raise_error ActionController::ParameterMissing
      expect{ get(:index, format: :json) }.
        to raise_error ActionController::ParameterMissing
    end

    it 'prevents getting model that is not permitted' do
      expect{ get(:index, model: 'unpermitted_models') }.
        to raise_error ActionController::RoutingError
      expect{ get(:index, format: :json, model: 'unpermitted_models') }.
        to raise_error ActionController::RoutingError
    end

    it 'returns table template on html format request' do
      DataTablesController.new.send('allowed_models').each do |model|
        get :index, model: model
        expect(response).to render_template("data_tables/index")
        expect(response).to render_template('layouts/application')
      end
    end

    it 'does not raise error on wrong parameter json format request' do
      get :index,
          format: :json,
          model: 'plant_lines',
          query: { plant_line_name: 'wrong!' }
      expect(response).to have_http_status(:success)
    end

    it 'does not render htmls on json format request' do
      get :index, format: :json, model: 'plant_populations'
      expect(response).not_to render_template('data_tables/index')
      expect(response).not_to render_template('layouts/application')
    end

    it 'returns datatables json on json format request' do
      pps = create_list(:plant_population, 2)
      get :index, format: :json, model: 'plant_populations'
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 2
      expect(json['data'].size).to eq 2
      expect(json['data'].map{ |pp| pp[-3] }).to match_array pps.map(&:id)
    end

    it 'supports query filtering on json format request' do
      pps = create_list(:plant_population, 2).map(&:id)
      get :index,
          format: :json,
          model: 'plant_populations',
          query: { id: pps[0] }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 1
      expect(json['data'].size).to eq 1
      expect(json['data'][0][-3]).to eq pps[0]
    end

    it 'prevents querying by unpermitted parameters' do
      create(:plant_line, common_name: 'cn')
      get :index,
          format: :json,
          model: 'plant_lines',
          query: { common_name: 'cn' }
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 0
      expect(json['data'].size).to eq 0
      expect(json['data']).to eq []
    end
  end
end
