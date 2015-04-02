require 'rails_helper'

RSpec.describe PlantTrial do
  describe '#filter' do
    it 'allow queries by project_descriptor' do
      pending 'implement factories and test querying by project descriptor'
      fail
    end

    it 'will only search by permitted params' do
      pending 'check no other parameters are allowed in queries'
      fail
    end
  end

  describe '#pluckable' do
    it 'gets proper data table columns' do
      pending 'test proper column plucking'
      fail
    end
  end

  describe '#table_data' do
    it 'orders plant trials by trial year' do
      pending 'check results ordering'
      fail
    end
  end
end
