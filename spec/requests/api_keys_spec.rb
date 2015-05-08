require 'rails_helper'

RSpec.describe "/api_key" do

  context "with no user signed in" do
    describe "GET /api_key" do
      it "redirects to referrer" do
        get "/api_key", {}, { 'HTTP_REFERER' => new_submission_path }
        expect(response).to redirect_to(new_submission_path)
      end
    end
  end

  context "with user signed in" do
    let(:user) { create :user }

    before { login_as(user) }

    describe "GET /api_key" do
      it "returns api key" do
        get "/api_key"
        expect(response).to be_success
        expect(response.body).to eq user.api_key.token
      end
    end
  end
end

