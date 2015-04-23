require 'rails_helper'

RSpec.describe SubmissionDecorator do
  describe '#submission_type' do
    it 'handles all submission types properly' do
      Submission.submission_types.keys.each do |submission_type|
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

    it 'provides correct datatables path for finalized submission' do
      submission = create(:finalized_submission)
      sd = SubmissionDecorator.decorate(submission)
      expect(sd.details_path).
        to include 'data_tables?model=plant_populations'
    end
  end
end
