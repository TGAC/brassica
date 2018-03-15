require 'rails_helper'

RSpec.describe "/api_key" do
  context "with no user signed in" do
    describe "GET /api_keys" do
      it "redirects to referrer" do
        get "/api_keys", params: {}, headers: { 'HTTP_REFERER' => new_submission_path }
        expect(response).to redirect_to(new_submission_path)
      end
    end
  end

  context "with user signed in" do
    let(:user) { create :user }

    before { login_as(user) }

    context "JSON format" do
      describe "GET /api_keys" do
        it "returns api key" do
          get "/api_keys", params: { format: :json }
          expect(response).to be_success
          expect(JSON.parse(response.body)['api_key']).to eq user.api_key.token
        end
      end
    end

    context "HTML format" do
      describe "GET /api_keys" do
        it "returns api key" do
          get "/api_keys", params: { format: :html }
          expect(response).to be_success
          expect(response).to render_template('api_keys/show')
        end
      end

      describe "PUT /api_keys/recreate" do
        it "renews api key" do
          api_key = user.api_key

          put "/api_keys/recreate", params: { format: :html }
          expect(response).to redirect_to("/api_keys")
          expect(user.reload.api_key.token).not_to eq api_key.token
        end
      end
    end
  end
end

