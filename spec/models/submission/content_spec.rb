require 'rails_helper'

RSpec.describe Submission::Content do
  let(:content) { { name: 'Bar' } }
  let(:submission) { Submission.new(content: content) }

  subject { described_class.new(submission) }

  context "with non-empty content" do
    it "allows dot syntax access" do
      expect(subject.name).to eq 'Bar'
    end

    it "allows hash-like access" do
      expect(subject[:name]).to eq 'Bar'
      expect(subject["name"]).to eq 'Bar'
    end
  end

  context "with empty content" do
    let(:content) { {} }
    it { should eq(OpenStruct.new) }
  end

  context "#update" do
    it "updates submission" do
      subject.update(:step01, name: 'Baz')
      expect(submission.content.name).to eq 'Baz'
      expect(submission.content.last_step).to eq "step01"
    end

    it "skips blank values in arrays" do
      subject.update(:step02, plant_line_list: ['', 'Baz', 'Blah'])
      expect(submission.content.plant_line_list).to eq ['Baz', 'Blah']
    end

    it "raises with invalid step" do
      expect { subject.update(:step_fiz, {}) }.to raise_error(Submission::InvalidStep, "No step step_fiz")
    end

    it 'preserves older keys with no new values' do
      subject.update(:step01, description: 'New, updated value')
      expect(submission.content.name).to eq 'Bar'
      expect(submission.content.description).to eq 'New, updated value'
    end
  end

  context "#append" do
    let(:content) {
      { int: 1, arr: ["a", "c"], h: { a: 1, c: 3 } }
    }

    it "appends new elements to array values" do
      subject.append(:step01, arr: ["b"])
      expect(submission.content.arr).to eq(["a", "c", "b"])
    end

    it "appends elements to hashes" do
      subject.append(:step01, h: { b: 2 })
      expect(submission.content.h).to eq("a" => 1, "b" => 2, "c" => 3)
    end

    it "fails for scalar values" do
      expect { subject.append(:step01, int: 23) }.to raise_error("Cannot append content for 'int'")
    end

    it "fails for incompatible values" do
      expect { subject.append(:step01, arr: 1) }.to raise_error("Cannot append content for 'arr'")
      expect { subject.append(:step01, arr: {}) }.to raise_error("Cannot append content for 'arr'")
      expect { subject.append(:step01, h: 1) }.to raise_error("Cannot append content for 'h'")
      expect { subject.append(:step01, h: []) }.to raise_error("Cannot append content for 'h'")
    end
  end

  context "#clear" do
    it "updates submission" do
      subject.clear(:name)
      expect(submission.content.to_h).to eq({})
    end
  end
end
