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

  describe '#parse_scores' do
    it 'does nothing with empty input' do
      input_is ''
      subject.send(:parse_scores)
      expect(subject.trait_scores).to eq({})
    end

    it 'does not ignore no-score rows' do
      input_is "plant 1\nplant 2"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {},
                'plant 2' => {} })
    end

    it 'records simple scores' do
      input_is "plant 1\t1  \nplant 2\t 2"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1'},
                'plant 2' => {0 => '2'} })
    end

    it 'records multiple sparse scores' do
      input_is "plant 1\t1\t2\nplant 2\t\t 3\nplant 3\t4"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1', 1 => '2'},
                'plant 2' => {1 => '3'},
                'plant 3' => {0 => '4'} })
    end

    it 'handles empty newlines properly' do
      input_is "plant 1\t1  \n\nplant X\t\nplant 2\t 2\n\n"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1'},
                'plant 2' => {0 => '2'},
                'plant X' => {} })
    end
  end

  describe '#call' do
    it 'resets step03 data when called' do
      upload.submission.content.update(:step03, trait_scores: { 'plant' => { 1 => '5' }})
      input_is ''
      subject.call
      expect(upload.submission.content.step03.trait_scores).to be_nil
    end

    it 'ignores any score in index grater than traits number' do
      upload.submission.content.update(:step02, trait_descriptor_list: ['trait',])
      input_is "id\ttrait\nplant 1\t1\t2"
      subject.call
      expect(subject.trait_mapping).
        to eq({0 => 0})
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1'} })
    end
  end

  def input_is(string)
    allow(subject).to receive(:input).and_return(StringIO.new(string))
  end
end
