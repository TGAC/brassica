require 'rails_helper'

RSpec.describe User, type: :model do

  subject { create(:user) }

  it { should validate_presence_of(:login) }
  it { should validate_uniqueness_of(:login).case_insensitive }
  it { should have_many(:analyses).with_foreign_key(:owner_id) }
  it { should have_many(:data_files).with_foreign_key(:owner_id).class_name("Analysis::DataFile") }

  it 'is forever' do
    u = create(:user)
    expect{ u.destroy }.to raise_error 'Entities of User cannot be destroyed!'
    expect(User.count).to eq 1
  end

  it 'gets api key on creation' do
    user = create(:user, api_key: nil)
    expect(user.reload.api_key).to be_present
  end
end
