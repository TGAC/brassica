require 'rails_helper'

RSpec.describe SubmissionDecorator do
  let(:population) {
    PlantPopulationSubmissionDecorator.decorate(create(:submission, :population))
  }
  let(:trial) {
    PlantTrialSubmissionDecorator.decorate(create(:submission, :trial))
  }

  describe '#submission_type_tag' do
    it 'handles all implemented submission types properly' do
      %i(population trial).each do |submission_type|
        submission = create(:submission, submission_type: submission_type)
        sd = SubmissionDecorator.decorate(submission)
        expect(sd.submission_type_tag).
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
        to raise_error('Must be implemented by subclasses')
      expect { sd.label }.
        to raise_error('Must be implemented by subclasses')
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

  describe '#name' do
    context 'when executed for plant population submission' do
      it 'returns empty string when there is no population name' do
        expect(population.name).to eq ''
      end

      it 'returns population name' do
        population.content.update(:step01, name: 'population_name')
        expect(population.name).to eq 'population_name'
      end
    end

    context 'when executed for plant trial submission' do
      it 'returns empty string when there is no trial name' do
        expect(trial.name).to eq ''
      end

      it 'returns trial name' do
        trial.content.update(:step01, plant_trial_name: 'trial_name')
        expect(trial.name).to eq 'trial_name'
      end
    end
  end

  describe '#description' do
    context 'when executed for plant population submission' do
      it 'returns empty string when there is no population description' do
        expect(population.description).to eq ''
      end

      it 'returns population description' do
        population.content.update(:step01, description: 'population_description')
        expect(population.description).to eq 'population_description'
      end
    end

    context 'when executed for plant trial submission' do
      it 'returns empty string when there is no trial description' do
        expect(trial.description).to eq ''
      end

      it 'returns trial description' do
        trial.content.update(:step01, plant_trial_description: 'trial_description')
        expect(trial.description).to eq 'trial_description'
      end
    end
  end

  describe '#affiliation' do
    context 'when executed for plant population submission' do
      it 'returns empty string when there is no owned_by metadata' do
        expect(population.affiliation).to eq ''
      end

      it 'returns population description' do
        population.content.update(:step01, owned_by: 'owner institute')
        expect(population.affiliation).to eq 'owner institute'
      end
    end

    context 'when executed for plant trial submission' do
      it 'returns empty string when there is no trial institute_id' do
        expect(trial.affiliation).to eq ''
      end

      it 'returns trial description' do
        trial.content.update(:step01, institute_id: 'owner institute')
        expect(trial.affiliation).to eq 'owner institute'
      end
    end
  end
end
