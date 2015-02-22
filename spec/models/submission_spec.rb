require 'rails_helper'

RSpec.describe Submission do
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
end
