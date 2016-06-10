require 'rails_helper'

RSpec.describe SubmissionDecorator do
  describe '#submission_type' do
    it 'handles all implemented submission types properly' do
      %i(population trial).each do |submission_type|
        submission = create(:submission, submission_type: submission_type)
        sd = SubmissionDecorator.decorate(submission)
        expect(sd.submission_type).
          to eq '<span class="text">' +
                I18n.t("submission.submission_type.#{submission_type}") +
                ':</span>'
      end
    end
  end

  describe '#further_details, #label' do
    it 'throw exceptions' do
      submission = create(:submission)
      sd = SubmissionDecorator.decorate(submission)
      expect { sd.further_details }.
        to raise_error('Should be extended by subclasses')
      expect { sd.label }.
        to raise_error('Should be extended by subclasses')
    end
  end

  describe '#details_path' do
    it 'provides empty path for unfinished submission' do
      submission = create(:submission)
      sd = SubmissionDecorator.decorate(submission)
      expect(sd.details_path).to eq '#'
    end

    %i(population trial).each do |submission_type|
      it "provides correct datatables path for finalized #{submission_type} submission" do
        submission = create(:finalized_submission, submission_type)
        sd = SubmissionDecorator.decorate(submission)
        expect(sd.details_path).
          to include "data_tables?model=plant_#{submission_type}s"
      end
    end
  end
end
