require 'rails_helper'

RSpec.describe Deposition do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:creators) }
  it { should validate_presence_of(:description) }

  let(:submission) { build(:submission, :population) }
  let(:user) { build(:user) }
  let(:submission_deposition) { Deposition.new(submission: submission) }
  let(:user_deposition) { Deposition.new(user: user) }

  describe '.new' do
    it 'creates proper defaults when submission is present' do
      submission.content.update(:step01, name: 'population_name')
      submission.content.update(:step01, description: 'population_description')
      submission.content.update(:step01, owned_by: 'Unknown organization')
      expect(submission_deposition).to be_valid
      expect(submission_deposition.title).to eq 'Plant population: population_name'
      expect(submission_deposition.description).to eq 'population_description'
      expect(submission_deposition.creators).
        to eq [{ name: submission.user.full_name, affiliation: 'Unknown organization' }]
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

  describe '#documents_to_deposit' do
    it 'returns empty hash for depositions without submission' do
      expect(user_deposition.documents_to_deposit).to be_empty
      pending 'Non-submission depositions not yet implemented'
      fail
    end

    it 'throws non implemented error for unsupported submission types' do
      submission = build(:submission, submission_type: :qtl)
      expect{ Deposition.new(submission: submission).documents_to_deposit }.
        to raise_error NotImplementedError
    end

    it 'calls exporter service for population documents' do
      expect_any_instance_of(Submission::PlantPopulationExporter).
        to receive(:documents)
      submission_deposition.documents_to_deposit
    end

    it 'calls exporter service for trial documents' do
      expect_any_instance_of(Submission::PlantTrialExporter).
        to receive(:documents)
      Deposition.new(submission: build(:submission, :trial)).documents_to_deposit
    end
  end
end
