require 'rails_helper'

RSpec.describe PlantPopulationsController do
  context '#index' do
    it 'returns search results' do
      populations = create_list(:plant_population, 2).map(&:name)
      get :index, format: :json, params: { search: { name: populations[0][1..-2] } }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['results'].size).to eq 1
      expect(json['results'][0]['name']).to eq populations[0]
    end
  end

  it 'filters forbidden results out' do
    create(:plant_population, user: create(:user), published: false, name: 'ppn_private')
    create(:plant_population, name: 'ppn_public')
    get :index, format: :json, params: { search: { name: 'ppn' } }
    expect(response.content_type).to eq 'application/json'
    json = JSON.parse(response.body)
    expect(json['results'].size).to eq 1
    expect(json['results'][0]['name']).to eq 'ppn_public'
  end
end
