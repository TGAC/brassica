require 'rails_helper'

RSpec.describe Submission::TraitScoreParser do

  let(:upload) { create(:upload) }
  subject { described_class.new(upload) }

  describe '#map_headers_to_traits' do
    context 'provided with input of incomplete content' do
      it 'reports less than three-column header as incomplete' do
        input_is 'single column name'
        subject.send(:map_headers_to_traits)
        expect(upload.errors[:file]).
          to eq ['No correct header provided. At least three columns are expected.']
      end

      it 'ignores three-column header' do
        input_is 'single column name,pa,oo'
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).to eq({})
      end

      it 'ignores all columns when no traits chosen' do
        input_is "id,pa,oo,first trait,\"second,trait_name\""
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).to eq({})
      end
    end

    context 'provided with trait-rich submission' do
      it 'maps columns by name' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['trait 1', 'trait 2'])
        input_is "id,pa,oo,trait 2,trait 1"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'recognizes names with commas and surrounding white chars' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['trait,1', 'trait 2'])
        input_is "id,pa,oo,trait 2  ,\"trait,1\""
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'honors proper trait sorting by index' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Ctrait', 'Atrait', 'Btrait'])
        input_is "id,pa,oo,Btrait,Atrait,Ctrait"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 2, 1 => 1, 2 => 0})
      end

      it 'uses natural ordering when no by-name mapping found' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
        input_is "id,pa,oo,trait 1,trait 2"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 1})
      end

      it 'works regardless traits are old or new' do
        td = create(:trait_descriptor, trait: create(:trait, name: 'old trait'))
        upload.submission.content.update(:step02, trait_descriptor_list: [td.id, 'new trait'])
        input_is "id,pa,oo,new trait,old trait"
        subject.send(:map_headers_to_traits)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'reports error on repetitive mapping' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
        input_is "id,pa,oo,Xtrait,Atrait"
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
      input_is "plant 1,pa,oo\nplant 2,pa,oo"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {},
                'plant 2' => {} })
    end

    it 'records simple scores' do
      input_is "plant 1,pa,oo,1  \nplant 2,pa,oo, 2"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1'},
                'plant 2' => {0 => '2'} })
    end

    it 'records multiple sparse scores' do
      input_is "plant 1,pa,oo,1,2\nplant 2,pa,oo,, 3\nplant 3,pa,oo,4"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1', 1 => '2'},
                'plant 2' => {1 => '3'},
                'plant 3' => {0 => '4'} })
    end

    it 'handles empty newlines properly' do
      input_is "plant 1,pa,oo,1  \n\nplant X,pa,oo,\nplant 2,pa,oo, 2\n\n"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1'},
                'plant 2' => {0 => '2'},
                'plant X' => {} })
    end

    it 'requires every line to provide accession-related information' do
      input_is "plant 1,pa,oo\nplant X,pa\nplant 2\n"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {} })
      expect(upload.logs).
        to include 'Ignored row for plant X since either Plant accession or Originating organisation is missing.'
      expect(upload.logs).
        to include 'Ignored row for plant 2 since either Plant accession or Originating organisation is missing.'
    end

    it 'parses accession information to a dedicated structure' do
      input_is "plant 1,pa,oo\nplant X,pa\nplant Y\nplant 2,pa2,oo"
      subject.send(:parse_scores)
      expect(subject.accessions).
        to eq({ 'plant 1' => { plant_accession: 'pa', originating_organisation: 'oo' },
                'plant 2' => { plant_accession: 'pa2', originating_organisation: 'oo' }})
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
      input_is "id,pa,oo,trait\nplant 1,pa,oo,1,2"
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
