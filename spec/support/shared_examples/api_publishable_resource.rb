RSpec.shared_examples "API-publishable resource" do |model_klass|
  model_name = model_klass.name.underscore

  let(:parsed_response) { JSON.parse(response.body) }

  context "with no api key" do
    describe "PATCH /api/v1/#{model_name.pluralize}/:id/publish" do
      let!(:resource) { create model_name }

      it "returns 401" do
        patch "/api/v1/#{model_name.pluralize}/#{resource.id}/publish"

        expect(response.status).to eq 401
        expect(parsed_response['reason']).not_to be_empty
      end
    end
  end

  context "with invalid api key" do
    let(:demo_key) { I18n.t('api.general.demo_key') }

    describe "PATCH /api/v1/#{model_name.pluralize}/:id/publish" do
      let!(:resource) { create model_name }

      it "returns 401" do
        patch "/api/v1/#{model_name.pluralize}/#{resource.id}/publish", {}, { "X-BIP-Api-Key" => "invalid" }

        expect(response.status).to eq 401
        expect(parsed_response['reason']).not_to be_empty
      end
    end
  end

  context "with valid api key" do
    let(:api_key) { create(:api_key) }

    describe "PATCH /api/v1/#{model_name.pluralize}/:id/publish" do
      context "with unpublished resource owned by API key owner" do
        let!(:resource) { create model_name, published: false, user: api_key.user }

        it "publishes resource" do
          patch "/api/v1/#{model_name.pluralize}/#{resource.id}/publish", { },
            { "X-BIP-Api-Key" => api_key.token }

          expect(response).to be_success
          expect(resource.reload).to be_published
        end
      end

      context "with published resource owned by API key owner" do
        let!(:resource) { create model_name, published: true, user: api_key.user }

        it "returns 403" do
          patch "/api/v1/#{model_name.pluralize}/#{resource.id}/publish", { },
            { "X-BIP-Api-Key" => api_key.token }

          expect(response.status).to eq 403
          expect(parsed_response['reason']).to eq("This resource is already published")
        end
      end
    end
  end
end
