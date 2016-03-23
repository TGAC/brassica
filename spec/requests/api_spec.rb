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

  # A special case test
  context 'when deleting related objects' do
    let!(:user) { create(:user) }
    let!(:parent_line) { create(:plant_line, user: user) }
    let!(:plant_lines) { create_list(:plant_line, 2, user: user) }
    let!(:plant_population) do
      create(:plant_population,
             user: user,
             male_parent_line: parent_line
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
      pending
      expect(plant_population.male_parent_line).to eq parent_line
      delete "/api/v1/plant_lines/#{parent_line.id}", {}, { "X-BIP-Api-Key" => api_key.token }

      expect(response.status).to eq 204
      expect(plant_population.reload.male_parent_line_id).to be_nil
    end

    it 'makes sure there are no habtm references left' do
      pending
      expect(plant_population.reload.plant_lines.count).to eq 2
      expect(PlantPopulationList.count).to eq 2
      delete "/api/v1/plant_lines/#{plant_population.plant_lines.first.id}", {}, { "X-BIP-Api-Key" => api_key.token }

      expect(response.status).to eq 204
      expect(PlantPopulationList.count).to eq 1
      expect(plant_population.plant_lines.count).to eq 1
    end
  end

end
