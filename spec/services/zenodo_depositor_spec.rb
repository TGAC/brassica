require 'rails_helper'

RSpec.describe ZenodoDepositor do
  let(:population_submission) { create(:submission, :population, :finalized, published: true) }
  let(:private_submission) { create(:submission, :population, :finalized, published: false) }
  let(:population_deposition) { Deposition.new(submission: population_submission) }
  let(:private_deposition) { Deposition.new(submission: private_submission) }

  it 'fails with error for broken deposition' do
    expect_any_instance_of(Typhoeus::Request).not_to receive(:run)
    error_msg = "Got nil or invalid Deposition. Unable to upload it to Zenodo."
    expect { deposit(nil) }.to raise_error(ArgumentError, error_msg)
    expect { deposit(Deposition.new) }.to raise_error(ArgumentError, error_msg)
    expect { deposit(Deposition.new(title: 't')) }.to raise_error(ArgumentError, error_msg)
  end

  it 'handles network errors gracefully' do
    allow_any_instance_of(ZenodoDepositor).
      to receive(:query_url).and_return('http://total.rubbish/')
    expect(deposit(population_deposition).user_log).
      to include "Zenodo service responded with invalid content. Unable to conclude data deposition."
  end

  context 'when provided with population submission deposition' do
    it 'calls deposition documents_to_deposit method' do
      expect(population_deposition).
        to receive(:documents_to_deposit).once.and_return({})
      deposit(population_deposition)
    end

    it 'does nothing for deposition of submission with no data' do
      expect_any_instance_of(Typhoeus::Request).not_to receive(:run)
      deposit(private_deposition)
    end

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
