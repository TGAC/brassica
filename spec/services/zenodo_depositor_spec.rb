require 'rails_helper'

RSpec.describe ZenodoDepositor do
  let(:population_submission) { create(:submission, :population, :finalized) }
  let(:population_deposition) { Deposition.new(submission: population_submission) }

  it 'does nothing for broken deposition' do
    expect_any_instance_of(Typhoeus::Request).not_to receive(:run)
    deposit(nil)
    deposit(Deposition.new)
    deposit(Deposition.new(title: 't'))
  end

  it 'handles network errors gracefully' do
    allow_any_instance_of(ZenodoDepositor).
      to receive(:query_url).and_return('http://total.rubbish/')
    expect(deposit(population_deposition).user_log).
      to include "Zenodo service responded with invalid content. Unable to conclude data deposition."
  end

  context 'when provided with correct population submission deposition' do
    it 'gets final deposition doi and saves it in submission' do
      service = deposit(population_deposition)
      expect(population_deposition.submission.doi).not_to be_nil
      expect(service.user_log).to be_empty
    end
  end

  private

  def deposit(deposition)
    service = ZenodoDepositor.new(deposition)
    VCR.use_cassette('zenodo') do
      service.call
    end
    service
  end
end
