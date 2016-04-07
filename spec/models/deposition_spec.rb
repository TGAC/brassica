require 'rails_helper'

RSpec.describe Deposition do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:creators) }
  it { should validate_presence_of(:description) }

  describe '.new' do
    let(:submission) { build(:submission, :population) }
    let(:user) { build(:user) }
    let(:submission_deposition) { Deposition.new(submission: submission) }
    let(:user_deposition) { Deposition.new(user: user) }

    it 'creates proper defaults when submission is present' do
      submission.content.update(:step01, name: 'population_name')
      submission.content.update(:step01, description: 'population_description')
      expect(submission_deposition).to be_valid
      expect(submission_deposition.title).to eq 'Plant population: population_name'
      expect(submission_deposition.description).to eq 'population_description'
      expect(submission_deposition.creators).to eq [{ name: submission.user.full_name }]
    end

    it 'creates proper defaults when user is present' do
      expect(user_deposition).not_to be_valid
      expect(user_deposition.creators).to eq [{ name: user.full_name }]
    end

    it 'required either submission or user to be present' do
      deposition = Deposition.new
      expect(deposition).not_to be_valid
      expect(deposition.errors[:submission]).to include 'can\'t be blank'
      expect(deposition.errors[:user]).to include 'can\'t be blank'
      submission_deposition.validate
      user_deposition.validate
      expect(user_deposition.errors[:user]).to be_empty
      expect(user_deposition.errors[:submission]).to be_empty
      expect(submission_deposition.errors[:user]).to be_empty
      expect(submission_deposition.errors[:submission]).to be_empty
    end
  end
end
