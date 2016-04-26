require 'rails_helper'

RSpec.describe Submission do

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:submission_type) }

  context "factory" do
    it "builds valid instance" do
      expect(build(:submission)).to be_valid

    end

    context "with :finalized trait" do
      it "creates valid finalized instance" do
        submission = build(:submission, :finalized)

        expect(submission).to be_valid
        expect(submission).to be_persisted
        expect(submission.submitted_object).to be_persisted
      end
    end
  end

  describe '#submission_type' do
    let(:submission) { build(:submission, :population) }

    it 'allows only certain submission type values' do
      %w(population trial qtl linkage_map).each do |t|
        submission.submission_type = t
        expect(submission.valid?).to be_truthy
        expect(submission.send(t+'?')).to be_truthy
      end
      expect { submission.submission_type = 'wrong_submission_type' }.
        to raise_error ArgumentError
    end

    it 'honors symbols as type values' do
      submission.submission_type = :population
      expect(submission.valid?).to be_truthy
    end

    it 'provides handy scopes to query certain types' do
      create(:submission, submission_type: :population)
      create(:submission, submission_type: :qtl)
      create(:submission, submission_type: :qtl)
      expect(Submission.qtl.count).to eq 2
      expect(Submission.population.count).to eq 1
      expect(Submission.linkage_map.count).to eq 0
      expect(Submission.trial.count).to eq 0
    end
  end

  describe '#submitted_object' do
    it 'behaves bad with unexpected submission type' do
      submission = create(:finalized_submission, :population)
      submission.update_column(:submission_type, 'unexpected')
      expect{ submission.submitted_object }.
        to raise_error NoMethodError
    end

    it 'provides nil object for unfinished submission' do
      expect(create(:submission).submitted_object).to eq nil
    end

    it 'returns associated object for finalized submissions' do
      expect(create(:finalized_submission, :population).submitted_object).
        to eq PlantPopulation.first
    end
  end

  describe '#content' do
    before {
      subject.content = {
        :step01 => { :foo => 1, :bar => "ble" },
        :step02 => { :baz => [1, 2, 3], :blah => {} }
      }
    }

    it 'allows to access step content' do
      expect(subject.content.step01.foo).to eq 1
      expect(subject.content.step01.bar).to eq "ble"
      expect(subject.content.step02.baz).to eq [1, 2, 3]
      expect(subject.content.step02.blah).to eq({})
    end
  end

  describe '#step' do
    it 'is set to default value when saving new record' do
      submission = build(:submission, step: nil)
      submission.save!
      expect(submission.step).to eq 'step01'
    end
  end

  describe '#step_forward' do
    let(:submission) { create(:submission, :population) }

    it 'moves one step forward' do
      expect { submission.step_forward }.to change { submission.step }.from('step01').to('step02')
    end

    it 'raises if at last step' do
      submission.update_attribute(:step, submission.steps.last)
      expect { submission.step_forward }.to raise_error(Submission::CantStepForward)
    end
  end

  describe '#step_back' do
    let(:submission) { create(:submission) }

    it 'moves one step back' do
      submission.update_attribute(:step, submission.steps.last)
      expect { submission.step_back }.to change { submission.step }.from('step04').to('step03')
    end

    it 'raises if at first step' do
      expect { submission.step_back }.to raise_error(Submission::CantStepBack)
    end
  end

  describe '#finalize' do
    let(:submission) { create(:submission, :population, finalized: false) }

    before do
      allow_any_instance_of(Submission::PlantPopulationFinalizer).to receive(:call)
    end

    it 'calls finalizer' do
      expect_any_instance_of(Submission::PlantPopulationFinalizer).to receive(:call)
      submission.update_attribute(:step, submission.steps.last)
      submission.update_attribute(:submitted_object_id, 1)
      submission.finalize
    end

    it 'raises if not at last step' do
      expect { submission.finalize }.to raise_error(Submission::CantFinalize)
    end
  end

  describe '#finalized' do
    it 'returns only finalized submissions' do
      create_list(:finalized_submission, 2)
      create_list(:submission, 1, finalized: false)
      expect(Submission.count).to eq 3
      expect(Submission.finalized.count).to eq 2
    end
  end

  describe '#depositable?' do
    it 'is false for unfinalized submissions' do
      expect(build(:submission, finalized: false).depositable?).to be_falsey
    end

    it 'is false for unpublishable submissions' do
      expect(build(:submission, :finalized).depositable?).to be_falsey
    end

    it 'is false for finalized, publishable submissions with assigned doi' do
      expect(build(:submission, :finalized, doi: 'x').depositable?).to be_falsey
    end

    it 'is false for finalized, publishable, revocable submissions' do
      submission = build(:submission, :finalized, publishable: true)
      expect(submission.depositable?).to be_falsey
    end

    it 'is true for finalized, publishable, irrevocable submissions without a doi' do
      submission = create(:submission, :finalized, publishable: true)
      submission.submitted_object.update_attribute(:published_on, Time.now - 8.days)
      expect(submission.depositable?).to be_truthy
    end
  end

  describe '#recent_first' do
    it 'orders submissions by update time' do
      ids = create_list(:submission, 7).map(&:id) +
            create_list(:submission, 13).map(&:id)
      expect(Submission.recent_first.map(&:id)).to eq ids.reverse
    end
  end

  describe "#save" do
    let(:submission) { create(:submission, :trial, finalized: false) }

    before do
      submission.content.update(:step03, upload_id: 7)
      submission.content.update(:step04, comments: "Very important comment")
      submission.save!
    end

    it "clears step03 of trial submission if step02 content is changed" do
      expect(submission.content.step03.to_h).not_to be_blank
      submission.content.update(:step02, trait_descriptor_list: ["trait X"])
      submission.save!
      expect(submission.reload.content.step03.to_h).to be_blank
    end

    it "does not clear step03 of trial submission if step02 content is not changed" do
      expect(submission.content.step03.to_h).not_to be_blank
      submission.content.update(:step02, trait_descriptor_list: [])
      submission.save!
      expect(submission.reload.content.step03.to_h).not_to be_blank
    end

    it "leaves step04 of trial submission intact if step02 content is changed" do
      expect(submission.content.step04.to_h).not_to be_blank
      submission.content.update(:step02, trait_descriptor_list: ["trait X"])
      submission.save!
      expect(submission.reload.content.step04.to_h).not_to be_blank
    end
  end

  describe '#object_name' do
    let(:population_submission) { create(:submission, :population) }
    let(:trial_submission) { create(:submission, :trial) }

    context 'when executed for plant population submission' do
      it 'returns empty string when there is no population name' do
        expect(population_submission.object_name).to eq ''
      end

      it 'returns population name' do
        population_submission.content.update(:step01, name: 'population_name')
        expect(population_submission.object_name).to eq 'population_name'
      end
    end

    context 'when executed for plant trial submission' do
      it 'returns empty string when there is no trial name' do
        expect(trial_submission.object_name).to eq ''
      end

      it 'returns trial name' do
        trial_submission.content.update(:step01, plant_trial_name: 'trial_name')
        expect(trial_submission.object_name).to eq 'trial_name'
      end
    end
  end

  describe '#object_description' do
    let(:population_submission) { create(:submission, :population) }
    let(:trial_submission) { create(:submission, :trial) }

    context 'when executed for plant population submission' do
      it 'returns empty string when there is no population description' do
        expect(population_submission.object_description).to eq ''
      end

      it 'returns population description' do
        population_submission.content.update(:step01, description: 'population_description')
        expect(population_submission.object_description).to eq 'population_description'
      end
    end

    context 'when executed for plant trial submission' do
      it 'returns empty string when there is no trial description' do
        expect(trial_submission.object_description).to eq ''
      end

      it 'returns trial description' do
        trial_submission.content.update(:step01, plant_trial_description: 'trial_description')
        expect(trial_submission.object_description).to eq 'trial_description'
      end
    end
  end
end
