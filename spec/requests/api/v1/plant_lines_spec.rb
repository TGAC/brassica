require 'rails_helper'

RSpec.describe "Plant lines v1 API" do

  context "with invalid api key" do
    describe "GET /api/v1/plant_lines" do
      it "returns 404" do
        get "/api/v1/plant_lines"

        expect(response.status).to eq 404
      end
    end

    describe "GET /api/v1/plant_lines/:id" do
      let!(:plant_line) { create :plant_line }

      it "returns 404" do
        get "/api/v1/plant_lines/#{plant_line.id}"

        expect(response.status).to eq 404
      end
    end
  end

  context "with valid api key" do
    let(:api_key) { create(:api_key) }
    let(:parsed_response) { JSON.parse(response.body) }

    describe "GET /api/v1/plant_lines" do
      describe "response" do
        let!(:plant_lines) { create_list(:plant_line, 3) }

        it "renders existing plant lines" do
          get "/api/v1/plant_lines", api_key: api_key.token

          expect(response).to be_success
          expect(parsed_response).to have_key("plant_lines")
          expect(parsed_response['plant_lines'].count).to eq 3
        end
      end

      describe "pagination" do

      end

      describe "filtering" do
        let(:filter_params) { { :search => 'foobar' } }

        it "uses .filter if params given" do
          expect(PlantLine).to receive(:filter).with(filter_params)

          get "/api/v1/plant_lines", api_key: api_key.token, plant_line: filter_params

          expect(response).to be_success
        end
      end
    end

    describe "GET /api/v1/plant_lines/:id" do
      let!(:plant_line) { create :plant_line }

      it "returns plant line" do
        get "/api/v1/plant_lines/#{plant_line.id}", api_key: api_key.token

        expect(response).to be_success
      end
    end
  end
end
