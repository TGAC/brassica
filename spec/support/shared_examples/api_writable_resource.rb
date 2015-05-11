RSpec.shared_examples "API-writable resource" do |model_klass|
  model_name = model_klass.name.underscore

  context "with invalid api key" do
    describe "POST /api/v1/#{model_name.pluralize}" do
      it "returns 404" do
        get "/api/v1/#{model_name.pluralize}"

        expect(response.status).to eq 404
      end
    end
  end

  context "with valid api key" do
    let(:api_key) { create(:api_key) }
    let(:parsed_response) { JSON.parse(response.body) }

    let(:required_attrs) { required_attributes(model_klass) }

    describe "POST /api/v1/#{model_name.pluralize}" do
      context "with valid attributes" do
        let(:model_attrs) {
          {}.tap do |attrs|
            required_attrs.each do |attr|
              attrs[attr] = "Foo"
            end
          end
        }

        it "creates " do
          expect {
            post "/api/v1/#{model_name.pluralize}", api_key: api_key.token, model_name => model_attrs
          }.to change {
            model_klass.count
          }.by(1)

          expect(response).to be_success
        end
      end

      context "with invalid attributes" do
      end

      context "with blacklisted params" do
      end

      context "with misnamed attributes" do
      end
    end
  end

  def required_attributes(model_klass)
    [].tap do |attrs|
      model_klass.validators.each do |validator|
        validator.attributes.each do |attr|
          attrs << attr
        end
      end
    end
  end
end
