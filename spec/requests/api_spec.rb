require 'rails_helper'

RSpec.describe "API V1" do

  Api.readable_models.each do |model_klass|
    describe model_klass do
      it_behaves_like "API-readable resource", model_klass
    end
  end

  Api.writable_models.each do |model_klass|
    describe model_klass do
      it_behaves_like "API-writable resource", model_klass
      it_behaves_like "API-deletable resource", model_klass
    end
  end

  Api.publishable_models.each do |model_klass|
    describe model_klass do
      it_behaves_like "API-publishable resource", model_klass
      it_behaves_like "API-revocable resource", model_klass
    end
  end

  # A special case test
  context 'when deleting related objects' do
    let!(:user) { create(:user) }
    let!(:parent_line) { create(:plant_line, user: user, published: false) }
    let!(:plant_lines) { create_list(:plant_line, 2, user: user, published: false) }
    let!(:plant_population) do
      create(:plant_population,
             user: user,
             male_parent_line: parent_line,
             published: false
      )
    end
    let!(:plant_population_list_1) do
      create(:plant_population_list,
                  user: user,
                  plant_population: plant_population,
                  plant_line: plant_lines.first)
    end
    let!(:plant_population_list_2) do
      create(:plant_population_list,
                  user: user,
                  plant_population: plant_population,
                  plant_line: plant_lines.second)
    end
    let!(:api_key) { user.api_key }

    it 'makes sure there are no dangling belongs_to references left' do
      expect(plant_population.male_parent_line).to eq parent_line
      delete "/api/v1/plant_lines/#{parent_line.id}", {}, { "X-BIP-Api-Key" => api_key.token }

      expect(response.status).to eq 204
      expect(plant_population.reload.male_parent_line_id).to be_nil
    end

    it 'makes sure there are no habtm references left' do
      expect(plant_population.reload.plant_lines.count).to eq 2
      expect(PlantPopulationList.count).to eq 2
      delete "/api/v1/plant_lines/#{plant_population.plant_lines.first.id}", {}, { "X-BIP-Api-Key" => api_key.token }

      expect(response.status).to eq 204
      expect(PlantPopulationList.count).to eq 1
      expect(plant_population.plant_lines.count).to eq 1
    end
  end

  context 'when submitting plant accessions' do
    let!(:user) { create(:user) }
    let!(:pl) { create(:plant_line) }
    let!(:pv) { create(:plant_variety) }
    let!(:api_key) { user.api_key }

    let(:parsed_response) { JSON.parse(response.body) }

    it 'does not accept plant accessions without PL or PV' do
      expect {
        post "/api/v1/plant_accessions", {
          plant_accession: {plant_accession: 'foo', plant_line_id: nil, plant_variety_id: nil}
        }, { "X-BIP-Api-Key" => api_key.token }
      }.to change { PlantAccession.count }.by(0)

      expect(response.status).to eq 422
      expect(parsed_response['errors'].length).to eq 2
      expect(parsed_response['errors'].first['message']).to eq 'A plant accession must be linked to either a plant line or a plant variety.'
      expect(parsed_response['errors'].second['message']).to eq 'A plant accession must be linked to either a plant line or a plant variety.'
    end

    it 'does not accept plant accessions with both PL and PV' do
      expect {
        post "/api/v1/plant_accessions", {
            plant_accession: {plant_accession: 'foo', plant_line_id: pl.id, plant_variety_id: pv.id}
        }, { "X-BIP-Api-Key" => api_key.token }
      }.to change { PlantAccession.count }.by(0)

      expect(response.status).to eq 422
      expect(parsed_response['errors'].length).to eq 2
      expect(parsed_response['errors'].first['message']).to eq 'A plant accession may not be simultaneously linked to a plant line and a plant variety.'
      expect(parsed_response['errors'].second['message']).to eq 'A plant accession may not be simultaneously linked to a plant line and a plant variety.'
    end

    it 'accepts plant accessions with either PL or PV but not both' do
      expect {
        post "/api/v1/plant_accessions", {
            plant_accession: {plant_accession: 'foo', plant_line_id: pl.id, plant_variety_id: nil}
        }, { "X-BIP-Api-Key" => api_key.token }
      }.to change { PlantAccession.count }.by(1)

      expect {
        post "/api/v1/plant_accessions", {
          plant_accession: {plant_accession: 'bar', plant_line_id: nil, plant_variety_id: pv.id}
        }, { "X-BIP-Api-Key" => api_key.token }
      }.to change { PlantAccession.count }.by(1)
    end
  end
end
