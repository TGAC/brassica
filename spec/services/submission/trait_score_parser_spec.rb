require 'rails_helper'

RSpec.describe Submission::TraitScoreParser do

  let(:upload) { create(:upload) }
  subject { described_class.new(upload) }

  describe '#map_headers_to_traits' do
    context 'provided with input of incomplete content' do
      it 'raise error on empty input file' do
        input_is ''
        expect { subject.send(:map_headers_to_traits) }.
          to raise_error EOFError
      end

      it 'ignores single column header' do
        input_is 'single column name no tabs'
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).to eq({})
      end

      it 'ignores all columns when no traits chosen' do
        input_is "id\tfirst trait\tsecond_trait_name"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).to eq({})
      end
    end

    context 'provided with trait-rich submission' do
      it 'maps columns by name' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['trait 1', 'trait 2'])
        input_is "id\ttrait 2\ttrait 1"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'honors proper trait sorting by name' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Ctrait', 'Atrait', 'Btrait'])
        input_is "id\tBtrait\tAtrait\tCtrait"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0, 2 => 2})
      end

      it 'uses natural ordering when no by-name mapping found' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
        input_is "id\ttrait 1\ttrait 2"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 1})
      end

      it 'works regardless traits are old or new' do
        td = create(:trait_descriptor, descriptor_name: 'old trait')
        upload.submission.content.update(:step02, trait_descriptor_list: [td.id, 'new trait'])
        input_is "id\t#{td.descriptor_name}\tnew trait"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'reports error on repetitive mapping' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
        input_is "id\tXtrait\tAtrait"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 0})
        expect(upload.errors[:file]).not_to be_empty
        expect(upload.errors[:file]).
          to eq ['Detected non unique column headers mapping to traits. Please check the column names.']
      end
    end
  end

  def input_is(string)
    allow(subject).to receive(:input).and_return(StringIO.new(string))
  end
end
