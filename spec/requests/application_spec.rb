require 'rails_helper'

RSpec.describe 'Application index' do
  describe 'GET /' do
    it 'shows no submission if none are finalized and published' do
      get '/'
      expect(response).to have_http_status(:success)
      expect(response).not_to render_template('submissions/_submissions_list')
    end

    it 'shows all submissions if less then 5 are finalized' do
      create_list(:finalized_submission, 2, published: true)
      create_list(:finalized_submission, 1, published: false)
      create_list(:submission, 1, finalized: false)
      get '/'
      expect(response).to have_http_status(:success)
      expect(response).to render_template('submissions/_submissions_list')
      expect(response.body).to include 'Latest user submissions'
      expect(response.body.scan('Submitted on').size).to eq 2
    end

    it 'shows at most 5 finalized published submissions' do
      create_list(:finalized_submission, 7, published: true)
      get '/'
      expect(response).to have_http_status(:success)
      expect(response.body.scan('Submitted on').size).to eq 5
    end
  end
end
