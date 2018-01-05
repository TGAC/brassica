RSpec.shared_examples "API-deletable resource" do |model_klass|
  model_name = model_klass.name.underscore

  let(:parsed_response) { JSON.parse(response.body) }
  let(:subject) { create(model_name.to_sym) }

  describe '#revocable?' do
    it 'implements revocable? method' do
      expect{ subject.revocable? }.not_to raise_error
    end

    it 'returns true for private objects not older than 1 week, false otherwise' do
      subject.update_attributes!(published: false, published_on: nil)
      expect(subject.reload.revocable?).to be_falsey

      subject.update_attributes!(published: true, published_on: Time.now)
      expect(subject.reload.revocable?).to be_truthy

      subject.update_attributes!(published: true, published_on: 8.days.ago)
      expect(subject.reload.revocable?).to be_falsey
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
        subject.update_attributes!(published: true, published_on: 8.days.ago)
        expect {
          delete "/api/v1/#{model_name.pluralize}/#{subject.id}", {}, { "X-BIP-Api-Key" => api_key.token }
        }.to change {
          model_klass.count
        }.by(0)

        expect(response.status).to eq 403
        expect(parsed_response['reason']).not_to be_empty
      end

      it 'destroys resource still in its revocability period' do
        subject.update_attributes!(published: true, published_on: Time.now)
        expect {
          delete "/api/v1/#{model_name.pluralize}/#{subject.id}", {}, { "X-BIP-Api-Key" => api_key.token }
        }.to change {
          model_klass.count
        }.by(-1)

        expect(response.status).to eq 204
      end

      it 'prevents destroying forbidden resource' do
        subject.update_attributes!(published: false)
        expect {
          delete "/api/v1/#{model_name.pluralize}/#{subject.id}", {}, { "X-BIP-Api-Key" => create(:api_key).token }
        }.to change {
          model_klass.count
        }.by(0)

        expect(response.status).to eq 401
        expect(parsed_response['reason']).not_to be_empty
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
