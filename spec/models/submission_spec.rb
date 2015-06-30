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
    let(:submission) { build(:submission) }

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
      # submission.submission_type = :population
      create(:submission)
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
      submission = create(:finalized_submission)
      submission.update_column(:submission_type, 'unexpected')
      expect{ submission.submitted_object }.
        to raise_error NoMethodError
    end

    it 'provides nil object for unfinished submission' do
      expect(create(:submission).submitted_object).to eq nil
    end

    it 'returns associated object for finalized submissions' do
      expect(create(:finalized_submission).submitted_object).
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
    let(:submission) { create(:submission) }

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
    let(:submission) { create(:submission, finalized: false) }

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

  describe '#recent_first' do
    it 'orders submissions by update time' do
      ids = create_list(:submission, 7).map(&:id) +
            create_list(:submission, 13).map(&:id)
      expect(Submission.recent_first.map(&:id)).to eq ids.reverse
    end
  end


end
