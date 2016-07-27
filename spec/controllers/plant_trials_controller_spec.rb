require 'rails_helper'

RSpec.describe PlantTrialsController do
  describe '#index' do
    it 'returns search results' do
      trials = create_list(:plant_trial, 2).map(&:project_descriptor)
      get :index, format: :json, search: { project_descriptor: trials[0][2..-1] }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['results'].size).to eq 1
      expect(json['results'][0]['project_descriptor']).to eq trials[0]
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

  describe '#show' do
    it 'returns plant trial layout image as data stream' do
      get :show, id: create(:plant_trial, :with_layout).id
      expect(response).to be_success
      expect(response.content_type).to eq 'image/jpeg'
      expect(response.headers.keys).to include 'Content-Disposition'
      expect(response.headers['Content-Disposition']).to include PlantTrial.first.layout_file_name
      expect(response.body.size).to eq 60983
    end

    it 'returns 404 for no-layout trial' do
      get :show, id: create(:plant_trial).id
      expect(response.status).to eq 404
    end

    it 'returns 404 for not-owned private trial' do
      get :show, id: create(:plant_trial, :with_layout, published: false).id
      expect(response.status).to eq 401
    end
  end
end
