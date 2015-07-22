RSpec.shared_examples "API-deletable resource" do |model_klass|
  model_name = model_klass.name.underscore
  let(:parsed_response) { JSON.parse(response.body) }
  let(:subject) { create(model_klass) }

  describe '#published?' do
    it 'implements published? method' do
      expect{ subject.published? }.not_to raise_error
    end

    it 'returns true for objects older than 1 week, false otherwise' do
      expect(subject.reload.published?).to be_falsey
      subject.update_attribute :updated_at, Time.now - 8.days
      expect(subject.reload.published?).to be_truthy
    end
  end

  context "with no api key" do
    describe "DELETE /api/v1/#{model_name.pluralize}/:id" do
      it "returns 401" do
        delete "/api/v1/#{model_name.pluralize}/#{subject.id}"

        expect(response.status).to eq 401
        expect(parsed_response['reason']).not_to be_empty
      end
    end
  end

  context "with valid but wrong api key" do
    let(:api_key) { create(:api_key) }

    describe "DELETE /api/v1/#{model_name.pluralize}/:id" do
      it "returns 401" do
        delete "/api/v1/#{model_name.pluralize}/#{subject.id}", {}, { "X-BIP-Api-Key" => api_key.token }

        expect(response.status).to eq 401
        expect(parsed_response['reason']).not_to be_empty
      end
    end
  end

  context "with valid api key" do
    let!(:api_key) { subject.user.api_key }

    describe "DELETE /api/v1/#{model_name.pluralize}/:id" do
      it 'prevents destroying published resource' do
        subject.update_attribute :updated_at, Time.now - 8.days
        expect {
          delete "/api/v1/#{model_name.pluralize}/#{subject.id}", {}, { "X-BIP-Api-Key" => api_key.token }
        }.to change {
          model_klass.count
        }.by(0)

        expect(response.status).to eq 403
        expect(parsed_response['reason']).not_to be_empty
      end

      it 'destroys resource still in its revocability period' do
        expect {
          delete "/api/v1/#{model_name.pluralize}/#{subject.id}", {}, { "X-BIP-Api-Key" => api_key.token }
        }.to change {
          model_klass.count
        }.by(-1)

        expect(response.status).to eq 204
      end

      it 'returns 404 for nonexistent resource' do
        expect {
          delete "/api/v1/#{model_name.pluralize}/505505", {}, { "X-BIP-Api-Key" => api_key.token }
        }.to change {
          model_klass.count
        }.by(0)

        expect(response.status).to eq 404
        expect(parsed_response['reason']).not_to be_empty
      end
    end
  end
end
