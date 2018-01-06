require 'rails_helper'

RSpec.describe TraitDescriptorsController do
  context '#index' do
    it 'returns search results' do
      traits = create_list(:trait_descriptor, 2).map(&:trait_name)
      get :index, format: :json, params: { search: { trait_name: traits[0][1..-2] } }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['results'].size).to eq 1
      expect(json['results'][0]['trait_name']).to eq traits[0]
    end
  end

  it 'filters forbidden results out' do
    create(:trait_descriptor, user: create(:user), published: false, trait: create(:trait, name: 'tdn_private'))
    create(:trait_descriptor, trait: create(:trait, name: 'tdn_public'))
    get :index, format: :json, params: { search: { trait_name: 'tdn' } }
    expect(response.content_type).to eq 'application/json'
    json = JSON.parse(response.body)
    expect(json['results'].size).to eq 1
    expect(json['results'][0]['trait_name']).to eq 'tdn_public'
  end
end
