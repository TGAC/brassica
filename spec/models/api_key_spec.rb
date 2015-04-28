require 'rails_helper'

RSpec.describe ApiKey do

  context "factory" do
    it "builds valid instance" do
      expect(build(:api_key)).to be_valid
    end
  end

end
