require 'rails_helper'

RSpec.describe PlantVarietiesController do
  context '#index' do
    it 'returns search results' do
      varieties = create_list(:plant_variety, 2).map(&:plant_variety_name)
      get :index, format: :json, params: { search: { plant_variety_name: varieties[0][1..-2] } }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['results'].size).to eq 1
      expect(json['results'][0]['plant_variety_name']).to eq varieties[0]
    end
  end

  it 'filters forbidden results out' do
    create(:plant_variety, user: create(:user), published: false, plant_variety_name: 'pvn_private')
    create(:plant_variety, plant_variety_name: 'pvn_public')
    get :index, format: :json, params: { search: { plant_variety_name: 'pvn' } }
    expect(response.content_type).to eq 'application/json'
    json = JSON.parse(response.body)
    expect(json['results'].size).to eq 1
    expect(json['results'][0]['plant_variety_name']).to eq 'pvn_public'
  end
end
