require 'rails_helper'

RSpec.describe Submission do

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:submission_type) }

  describe '#submission_type' do
    let(:submission) { build(:submission) }

    it 'allows only certain submission type values' do
      %w(population traits qtl linkage_map).each do |t|
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
      expect(Submission.traits.count).to eq 0
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

    it 'updated submission' do
      submission.update_attribute(:step, submission.steps.last)
      expect { submission.finalize }.to change { submission.finalized? }.from(false).to(true)
    end

    it 'calls finalizer' do
      expect_any_instance_of(Submission::PlantPopulationFinalizer).to receive(:call)
      submission.update_attribute(:step, submission.steps.last)
      submission.finalize
    end

    it 'raises if not at last step' do
      expect { submission.finalize }.to raise_error(Submission::CantFinalize)
    end
  end

end
