require 'rails_helper'

RSpec.describe OrcidClient do
  describe '#get_user_data' do
    it 'loads user full_name from orcid' do
      extra_info = OrcidClient.get_user_data ENV['ORCID_TEST_UID']
      expect(extra_info).not_to eq nil
      expect(extra_info[:status]).to eq :ok
      expect(extra_info[:full_name]).to eq ENV['ORCID_TEST_FULL_NAME']
    end

    it 'generates warning but goes on when wrong orcid id' do
      extra_info = OrcidClient.get_user_data 'error-0000-0002-3822-5163'
      expect(extra_info).not_to eq nil
      expect(extra_info[:status]).to eq :error
      expect(extra_info[:message]).
        to include 'Problem accessing public ORCiD API for uid'
    end
  end
end
