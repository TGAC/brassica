require 'rails_helper'

RSpec.describe PlantLinesController do
  context '#index' do
    it 'returns table template on html format request' do
      get :index
      expect(response).to render_template('plant_lines/index')
      expect(response).to render_template('layouts/application')
    end

    it 'does not raise error on wrong parameter json format request' do
      get :index, format: :json, query: { plant_line_name: 'wrong!' }
      expect(response).to have_http_status(:success)
    end

    it 'does not render htmls on json format request' do
      get :index, format: :json
      expect(response).not_to render_template('plant_lines/index')
      expect(response).not_to render_template('layouts/application')
    end

    it 'returns datatables json on json format request' do
      plns = create_list(:plant_line, 2).map(&:plant_line_name)
      get :index, format: :json, query: { plant_line_name: plns }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 2
      expect(json['data'].size).to eq 2
      expect(json['data'][1].size).to eq 7
      expect(json['data'].map(&:first)).to match_array plns
    end

    it 'prevents querying by unpermitted parameters' do
      create(:plant_line, common_name: 'cn', plant_line_name: 'pln')
      create(:plant_line, common_name: 'cn', plant_line_name: 'nlp')
      create(:plant_line, common_name: 'nc', plant_line_name: 'pln')
      get :index,
          format: :json,
          query: { common_name: 'cn', plant_line_name: ['pln'] }
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 2
      expect(json['data'].size).to eq 2
      expect(json['data'].map(&:first)).to match_array ['pln','pln']
      expect(json['data'].map(&:third)).to match_array ['cn','nc']
    end

    it 'returns search results and provides PL id in the first element' do
      plns = create_list(:plant_line, 2).map(&:plant_line_name)
      get :index, format: :json, search: { plant_line_name: plns[0][1..-2] }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['recordsTotal']).to eq 1
      expect(json['data'].size).to eq 1
      expect(json['data'][0].size).to eq 7
      expect(json['data'][0][0]).to eq plns[0]
    end
  end
end
