require 'rails_helper'

RSpec.describe Submission::Content do
  let(:content) { { step01: { name: 'Bar' } } }
  let(:submission) { Submission.new(content: content) }

  subject { described_class.new(submission) }

  it "allows to access submission's step contents" do
    expect(subject.step01.name).to eq 'Bar'
    expect(subject[:step01].name).to eq 'Bar'
  end

  it "returns empty struct for each blank step" do
    expect(subject.step02).to eq(OpenStruct.new)
    expect(subject.step03).to eq(OpenStruct.new)
    expect(subject.step04).to eq(OpenStruct.new)
  end

  context "#update" do
    it "updates submission" do
      subject.update(:step01, name: 'Baz')
      expect(submission.content.step01.name).to eq 'Baz'
    end

    it "skips blank values in arrays" do
      subject.update(:step02, plant_line_list: ['', 'Baz', 'Blah'])
      expect(submission.content.step02.plant_line_list).to eq ['Baz', 'Blah']
    end

    it "raises with invalid step" do
      expect { subject.update(:step_fiz, {}) }.to raise_error(Submission::InvalidStep, "No step step_fiz")
    end

    it 'preserves older keys with no new values' do
      subject.update(:step01, description: 'New, updated value')
      expect(submission.content.step01.name).to eq 'Bar'
      expect(submission.content.step01.description).to eq 'New, updated value'
    end
  end

  context "#append" do
    let(:content) {
      { step01: { int: 1, arr: ["a", "c"], h: { a: 1, c: 3 } } }
    }

    it "appends new elements to array values" do
      subject.append(:step01, arr: ["b"])
      expect(submission.content.step01.arr).to eq(["a", "c", "b"])
    end

    it "appends elements to hashes" do
      subject.append(:step01, h: { b: 2 })
      expect(submission.content.step01.h).to eq("a" => 1, "b" => 2, "c" => 3)
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
      subject.clear(:step01)
      expect(submission.content.step01.to_h).to eq({})
    end

    it "raises with invalid step" do
      expect { subject.clear(:step_fiz) }.to raise_error(Submission::InvalidStep, "No step step_fiz")
    end
  end
end
