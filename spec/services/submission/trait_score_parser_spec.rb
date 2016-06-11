require 'rails_helper'

RSpec.describe Submission::TraitScoreParser do

  let(:upload) { create(:upload) }
  subject { described_class.new(upload) }

  describe '#parse_header' do
    context 'provided with input of incomplete content' do
      it 'reports less than three-column header as incomplete' do
        input_is 'single column name'
        subject.send(:parse_header)
        expect(upload.errors[:file]).
          to eq ['No correct header provided. At least four columns are expected.']
      end

      it 'does nothing with a three-column header' do
        input_is 'single column name,Plant accession,oo,pl'
        subject.send(:parse_header)
        expect(subject.trait_mapping).to eq({})
      end

      it 'ignores all columns when no traits were chosen' do
        input_is "id,Plant accession,oo,pl,first trait,\"second,trait_name\""
        subject.send(:parse_header)
        expect(subject.trait_mapping).to eq({})
      end

      it 'complains if there is no Plant accession column' do
        input_is 'id,pa,oo,pl'
        subject.send(:parse_header)
        expect(upload.errors[:file]).
          to eq ['No correct header provided. Please provide the \"Plant accession\" column.']
      end

      it 'complains if there is neither Plant line nor Plant variety column' do
        input_is 'id,Plant accession,oo,pl'
        subject.send(:parse_header)
        expect(upload.errors[:file]).
          to eq ['No correct header provided. Please provide either the \"Plant line\" or the \"Plant variety\" column.']
      end
    end

    context 'provided with trait-rich submission' do
      it 'maps columns by name' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['trait 1', 'trait 2'])
        input_is "id,Plant accession,oo,Plant line,trait 2,trait 1"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'recognizes names with commas and surrounding white chars' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['trait,1', 'trait 2'])
        input_is "id,Plant accession,oo,Plant line,trait 2  ,\"trait,1\""
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'honors proper trait sorting by index' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Ctrait', 'Atrait', 'Btrait'])
        input_is "id,Plant accession,oo,Plant line,Btrait,Atrait,Ctrait"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 2, 1 => 1, 2 => 0})
      end

      it 'uses natural ordering when no by-name mapping found' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
        input_is "id,Plant accession,oo,Plant line,trait 1,trait 2"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 1})
      end

      it 'works regardless traits are old or new' do
        td = create(:trait_descriptor, trait: create(:trait, name: 'old trait'))
        upload.submission.content.update(:step02, trait_descriptor_list: [td.id, 'new trait'])
        input_is "id,Plant accession,oo,Plant line,new trait,old trait"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 1, 1 => 0})
      end

      it 'reports error on repetitive mapping' do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
        input_is "id,Plant accession,oo,Plant line,Xtrait,Atrait"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 0})
        expect(upload.errors[:file]).not_to be_empty
        expect(upload.errors[:file]).
          to eq ['Detected non unique column headers mapping to traits. Please check the column names.']
      end
    end

    context 'provided with submission with technical replicates' do
      before :each do
        upload.submission.content.update(:step02, trait_descriptor_list: ['Atrait', 'Btrait'])
      end

      it 'correctly assigns well-named and ordered trait columns' do
        input_is "id,Plant accession,oo,Plant line,Atrait rep1,Atrait rep2,Atrait rep3,Btrait rep1,Btrait rep2"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 0, 2 => 0, 3 => 1, 4 => 1})
        expect(subject.replicate_numbers).
          to eq({0 => 1, 1 => 2, 2 => 3, 3 => 1, 4 => 2})
      end

      it 'correctly assigns well-named but misordered trait columns' do
        input_is "id,Plant accession,oo,Plant line,Atrait rep1,Btrait rep2,Atrait rep3,Atrait rep2,Btrait rep1"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 1, 2 => 0, 3 => 0, 4 => 1})
        expect(subject.replicate_numbers).
          to eq({0 => 1, 1 => 2, 2 => 3, 3 => 2, 4 => 1})
      end

      it 'correctly assigns, by index, misnamed trait columns' do
        input_is "id,Plant accession,oo,Plant line,first rep1,first rep2,first rep3,second rep1,second rep2,second rep3,second rep4"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 0, 2 => 0, 3 => 1, 4 => 1, 5 => 1, 6 => 1})
        expect(subject.replicate_numbers).
          to eq({0 => 1, 1 => 2, 2 => 3, 3 => 1, 4 => 2, 5 => 3, 6 => 4})
      end

      it 'tolerates traits with and without replicates' do
        input_is "id,Plant accession,oo,Plant line,first rep1,first rep2,second"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 0, 2 => 1})
        expect(subject.replicate_numbers).
          to eq({0 => 1, 1 => 2, 2 => 0})
      end

      it 'treats empty header as a no-replicate trait' do
        input_is "id,Plant accession,oo,Plant line,first rep1,,first rep2,second"
        subject.send(:parse_header)
        expect(subject.trait_mapping).
          to eq({0 => 0, 1 => 1, 2 => 1, 3 => 2})
        expect(subject.replicate_numbers).
          to eq({0 => 1, 1 => 0, 2 => 2, 3 => 0})
      end

      it 'reports read replicate numbers in user log' do
        input_is "id,Plant accession,oo,Plant line,first rep1,first rep2"
        subject.send(:parse_header)
        expect(upload.logs).
          to include "   - Detected technical replicate number 1"
        expect(upload.logs).
          to include "   - Detected technical replicate number 2"
      end

      it 'does not report repetitive mapping' do
        input_is "id,Plant accession,oo,Plant line,Atrait rep1,Atrait rep2"
        subject.send(:parse_header)
        expect(upload.errors[:file]).to be_empty
      end
    end

    context 'provided with header containing design factors' do
      it 'records empty array for input with no design factors' do
        input_is "id,Plant accession,oo,Plant line"
        subject.send(:parse_header)
        expect(subject.design_factor_names).to eq []
      end

      it 'correctly records the array of design factor names' do
        input_is "id,polytunnel,rep,sub_block,pot_number,Plant accession,oo,Plant line"
        subject.send(:parse_header)
        expect(subject.design_factor_names).to eq ['polytunnel', 'rep', 'sub_block', 'pot_number']
      end

      it 'accepts empty design factors' do
        input_is "id,,rep,,pot_number,Plant accession,Originating organisation,Plant line"
        subject.send(:parse_header)
        expect(subject.design_factor_names).to eq ['', 'rep', '', 'pot_number']
      end
    end

    context 'for plant line or plant variety information' do
      it 'detects Plant line column' do
        input_is "id,Plant accession,Originating organisation,Plant line"
        subject.send(:parse_header)
        expect(subject.instance_variable_get(:@line_or_variety)).to eq 'PlantLine'
      end

      it 'detects Plant variety column' do
        input_is "id,Plant accession,Originating organisation,Plant variety"
        subject.send(:parse_header)
        expect(subject.instance_variable_get(:@line_or_variety)).to eq 'PlantVariety'
      end

      it 'in unusual case of having both relations, prefer Plant line' do
        input_is "id,Plant accession,Originating organisation,Plant variety,Plant line"
        subject.send(:parse_header)
        expect(subject.instance_variable_get(:@line_or_variety)).to eq 'PlantLine'
      end
    end
  end

  describe '#parse_scores' do
    before :each do
      subject.instance_variable_set(:@trait_mapping, {0 => 0, 1 => 1})
      subject.instance_variable_set(:@design_factor_names, [])
      subject.instance_variable_set(:@line_or_variety, 'PlantLine')
    end

    it 'does nothing with empty input' do
      input_is ''
      subject.send(:parse_scores)
      expect(subject.trait_scores).to eq({})
    end

    it 'does not ignore no-score rows' do
      input_is "plant 1,pa,oo,pl\nplant 2,pa,oo,pl"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {},
                'plant 2' => {} })
    end

    it 'records simple scores' do
      input_is "plant 1,pa,oo,pl,1  \nplant 2,pa,oo,pl, 2"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1'},
                'plant 2' => {0 => '2'} })
    end

    it 'records multiple sparse scores' do
      input_is "plant 1,pa,oo,pl,1,2\nplant 2,pa,oo,pl,, 3\nplant 3,pa,oo,pl,4"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1', 1 => '2'},
                'plant 2' => {1 => '3'},
                'plant 3' => {0 => '4'} })
    end

    it 'handles empty newlines properly' do
      input_is "plant 1,pa,oo,pl,1  \n\nplant X,pa,oo,pl,\nplant 2,pa,oo,pl, 2\n\n"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {0 => '1'},
                'plant 2' => {0 => '2'},
                'plant X' => {} })
    end

    it 'requires each line to provide accession-related information' do
      input_is "plant 1,pa,oo,pl\nplant X,pa\nplant 2\n"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => {} })
      expect(upload.logs).
        to include 'Ignored row for plant X since either Plant accession or Originating organisation is missing.'
      expect(upload.logs).
        to include 'Ignored row for plant 2 since either Plant accession or Originating organisation is missing.'
    end

    it 'parses accession information to a dedicated structure' do
      input_is "plant 1,pa,oo,pl\nplant X,pa\nplant Y\nplant 2,pa2,oo,pl"
      subject.send(:parse_scores)
      expect(subject.accessions).
        to eq({ 'plant 1' => { plant_accession: 'pa', originating_organisation: 'oo' },
                'plant 2' => { plant_accession: 'pa2', originating_organisation: 'oo' }})
    end

    it 'ignores scores beyond number of trait columns' do
      input_is "plant 1,pa,oo,pl,1,2,3"
      subject.send(:parse_scores)
      expect(subject.trait_scores).
        to eq({ 'plant 1' => { 0 => '1', 1 => '2' } })
    end

    it 'parses Plant line name information' do
      input_is "plant 1,pa,oo,pl"
      subject.send(:parse_scores)
      expect(subject.lines_or_varieties).
        to eq({ 'plant 1' => { relation_class_name: 'PlantLine', relation_record_name: 'pl' }})
    end

    it 'parses Plant variety name information' do
      subject.instance_variable_set(:@line_or_variety, 'PlantVariety')
      input_is "plant 1,pa,oo,pv"
      subject.send(:parse_scores)
      expect(subject.lines_or_varieties).
        to eq({ 'plant 1' => { relation_class_name: 'PlantVariety', relation_record_name: 'pv' }})
    end

    context 'provided with data containing design factors' do
      before :each do
        subject.instance_variable_set(:@design_factor_names, ['polytunnel', 'rep', 'sub_block', 'pot_number'])
      end

      it 'records as many design factors as available' do
        input_is "plant 1,1\nplant 2\nplant 3,1,2,3,4,pa,oo"
        subject.send(:parse_scores)
        expect(subject.design_factors).
          to eq({ 'plant 1' => ['1'], 'plant 2' => [], 'plant 3' => ['1', '2', '3', '4'] })
      end

      it 'does not break when encountering empty lines' do
        input_is "plant 1,1\n\nplant 3,1"
        subject.send(:parse_scores)
        expect(subject.design_factors).
          to eq({ 'plant 1' => ['1'], 'plant 3' => ['1'] })
      end

      it 'does not interfere with reading other information' do
        input_is "plant 1,4,4,X,4,pa,oo,pl,1,2"
        subject.send(:parse_scores)
        expect(subject.design_factors).
          to eq({ 'plant 1' => ['4', '4', 'X', '4'] })
        expect(subject.trait_scores).
          to eq({ 'plant 1' => { 0 => '1', 1 => '2' } })
        expect(subject.accessions).
          to eq({ 'plant 1' => { plant_accession: 'pa', originating_organisation: 'oo' } })
        expect(subject.lines_or_varieties).
          to eq({ 'plant 1' => { relation_class_name: 'PlantLine', relation_record_name: 'pl' }})
      end
    end
  end

  describe '#split_to_trait_and_replicate' do
    it 'returns safe blanks for broken input' do
      expect(subject.send(:split_to_trait_and_replicate, nil)).to eq ['',0]
      expect(subject.send(:split_to_trait_and_replicate, '')).to eq ['',0]
    end

    it 'returns original input if no replicate was found' do
      expect(subject.send(:split_to_trait_and_replicate, 'a trait name')).
        to eq ['a trait name', 0]
      expect(subject.send(:split_to_trait_and_replicate, 'wrong_rep1 marker')).
        to eq ['wrong_rep1 marker', 0]
    end

    it 'detects replicate number and strips it off the trait name' do
      expect(subject.send(:split_to_trait_and_replicate, 'a trait namerep11')).
        to eq ['a trait name', 11]
      expect(subject.send(:split_to_trait_and_replicate, "trait with marker  rep0\t ")).
        to eq ["trait with marker", 0]
    end
  end

  describe '#call' do
    it 'resets step04 data when called' do
      upload.submission.content.update(:step04, trait_scores: { 'plant' => { 1 => '5' }})
      input_is ''
      subject.call
      expect(upload.submission.content.step04.trait_scores).to be_nil
      expect(upload.submission.content.step04.trait_mapping).to be_nil
      expect(upload.submission.content.step04.replicate_numbers).to be_nil
      expect(upload.submission.content.step04.design_factors).to be_nil
      expect(upload.submission.content.step04.design_factor_names).to be_nil
      expect(upload.submission.content.step04.accessions).to be_nil
      expect(upload.submission.content.step04.lines_or_varieties).to be_nil
    end

    it 'ignores any score in index grater than traits number' do
      upload.submission.content.update(:step02, trait_descriptor_list: ['trait'])
      input_is "id,Plant accession,oo,Plant variety,trait\nplant 1,pa,oo,pv,1,2"
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
