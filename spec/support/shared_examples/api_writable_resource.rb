RSpec.shared_examples "API-writable resource" do |model_klass|
  model_name = model_klass.name.underscore

  context "with no api key" do
    describe "POST /api/v1/#{model_name.pluralize}" do
      it "returns 401" do
        get "/api/v1/#{model_name.pluralize}"

        expect(response.status).to eq 401
      end
    end
  end

  context "with invalid api key" do
    describe "POST /api/v1/#{model_name.pluralize}" do
      it "returns 401" do
        get "/api/v1/#{model_name.pluralize}", {}, { "X-BIP-Api-Key" => "invalid" }

        expect(response.status).to eq 401
      end
    end
  end

  context "with valid api key" do
    let(:api_key) { create(:api_key) }
    let(:parsed_response) { JSON.parse(response.body) }

    let(:required_attrs) { required_attributes(model_klass) - [:user]}

    describe "POST /api/v1/#{model_name.pluralize}" do
      context "with valid attributes" do
        let(:model_attrs) {
          {}.tap do |attrs|
            required_attrs.each do |attr|
              attrs[attr] = "Foo"
            end
          end
        }

        it "creates an object " do
          expect {
            post "/api/v1/#{model_name.pluralize}", { model_name => model_attrs }, { "X-BIP-Api-Key" => api_key.token }
          }.to change {
            model_klass.count
          }.by(1)

          expect(response).to be_success
          expect(parsed_response).to have_key(model_name)
        end
      end

      context "with invalid params" do
        let(:model_attrs) {
          {}.tap do |attrs|
            required_attrs.each do |attr|
              attrs[attr] = ""
            end
          end
        }

        it "returns errors" do
          expect {
            post "/api/v1/#{model_name.pluralize}", { model_name => model_attrs }, { "X-BIP-Api-Key" => api_key.token }
          }.not_to change {
            model_klass.count
          }

          expect(response.status).to eq 422
          expect(parsed_response).to have_key("errors")
          expect(parsed_response['errors'].first).
            to eq('attribute' => required_attrs.first.to_s, 'message' => "Can't be blank")
        end
      end

      context "with misnamed params" do
        let(:model_attrs) {
          { foo: "bar" }
        }

        it "returns errors" do
          expect {
            post "/api/v1/#{model_name.pluralize}", { model_name => model_attrs }, { "X-BIP-Api-Key" => api_key.token }
          }.not_to change {
            model_klass.count
          }

          expect(response.status).to eq 422
          expect(parsed_response).to have_key("errors")
          expect(parsed_response['errors'].first).
            to eq('attribute' => 'foo', 'message' => 'Unrecognized attribute name')
        end
      end
    end
  end

  def required_attributes(model_klass)
    model_klass.validators.map(&:attributes).flatten.uniq
  end

end
