RSpec.shared_examples "API resource" do |model_name, model_klass|
  context "with invalid api key" do
    describe "GET /api/v1/#{model_name.pluralize}" do
      it "returns 404" do
        get "/api/v1/#{model_name.pluralize}"

        expect(response.status).to eq 404
      end
    end

    describe "GET /api/v1/#{model_name.pluralize}/:id" do
      let!(:resource) { create model_name }

      it "returns 404" do
        get "/api/v1/#{model_name.pluralize}/#{resource.id}"

        expect(response.status).to eq 404
      end
    end
  end

  context "with valid api key" do
    let(:api_key) { create(:api_key) }
    let(:parsed_response) { JSON.parse(response.body) }

    describe "GET /api/v1/#{model_name.pluralize}" do
      describe "response" do
        let!(:resources) { create_list(model_name, 3) }

        it "renders existing resources" do
          get "/api/v1/#{model_name.pluralize}", api_key: api_key.token

          expect(response).to be_success
          expect(parsed_response).to have_key(model_name.pluralize)
          expect(parsed_response[model_name.pluralize].count).to eq resources.size
        end
      end

      describe "pagination" do
        it "supports pagination" do
          pending
          fail
        end
      end

      describe "filtering" do
        let(:filter_params) { { :search => 'foobar' } }

        it "uses .filter if params given" do
          expect(model_klass).to receive(:filter).with(filter_params)

          get "/api/v1/#{model_name.pluralize}", api_key: api_key.token, model_name => filter_params

          expect(response).to be_success
        end
      end
    end

    describe "GET /api/v1/#{model_name.pluralize}/:id" do
      let!(:resource) { create model_name }

      it "returns requested resource" do
        get "/api/v1/#{model_name.pluralize}/#{resource.id}", api_key: api_key.token

        expect(response).to be_success
      end
    end
  end
end
