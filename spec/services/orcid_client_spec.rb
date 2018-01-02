require 'rails_helper'

RSpec.describe OrcidClient do
  describe '#get_user_data' do
    before { WebMock.allow_net_connect! }

    it 'loads user full_name from orcid' do
      extra_info = OrcidClient.get_user_data ENV['ORCID_TEST_UID']
      expect(extra_info).not_to eq nil
      expect(extra_info[:status]).to eq :ok
      # NOTE: ORCiD Sandbox ceased to send user's full name
      expect(extra_info[:full_name]).to eq ENV['ORCID_TEST_FULL_NAME']
    end

    it 'generates warning but goes on when wrong orcid id' do
      pending 'suspended orcid text due to (unintended?) orcid API change'
      fail
      extra_info = OrcidClient.get_user_data 'error-0000-0002-3822-5163'
      expect(extra_info).not_to eq nil
      expect(extra_info[:status]).to eq :error
      expect(extra_info[:message]).
        to include 'Problem accessing public ORCiD API for uid'
    end
  end
end
