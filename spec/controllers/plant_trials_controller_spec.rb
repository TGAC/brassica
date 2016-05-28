require 'rails_helper'

RSpec.describe PlantTrialsController do
  context '#index' do
    it 'returns search results' do
      trials = create_list(:plant_trial, 2).map(&:project_descriptor)
      get :index, format: :json, search: { project_descriptor: trials[0][2..-1] }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['results'].size).to eq 1
      expect(json['results'][0]['project_descriptor']).to eq trials[0]
    end
  end

  it 'filters forbidden results out' do
    create(:plant_trial, user: create(:user), published: false, project_descriptor: 'ppn_private')
    create(:plant_trial, project_descriptor: 'ppn_public')
    get :index, format: :json, search: { project_descriptor: 'ppn' }
    expect(response.content_type).to eq 'application/json'
    json = JSON.parse(response.body)
    expect(json['results'].size).to eq 1
    expect(json['results'][0]['project_descriptor']).to eq 'ppn_public'
  end
end
