require 'rails_helper'

RSpec.describe PlantVarietiesController do
  context '#index' do
    it 'returns search results' do
      varieties = create_list(:plant_variety, 2).map(&:plant_variety_name)
      get :index, format: :json, search: { plant_variety_name: varieties[0][1..-2] }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json[0]['plant_variety_name']).to eq varieties[0]
    end
  end
end
