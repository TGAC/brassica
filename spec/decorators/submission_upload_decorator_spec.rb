require 'rails_helper'

RSpec.describe SubmissionUploadDecorator do
  let(:sd) do
    SubmissionUploadDecorator.decorate(
      create(:upload)
    )
  end

  describe '#parser_summary' do
    it 'does not misbehave on null input' do
      expect(sd.parser_summary).to eq ['Uploaded file parsing summary:']
    end

    it 'calculates proper histogram' do
      traits = ['traitZ', 'traitX', 'traitY']
      scores = {
        'p1' => {},
        'p2' => { 1 => 'x' },
        'p3' => { 0 => 'y', 2 => 'z' },
        'p4' => { 2 => '', 3 => 'r' }
      }
      accessions = {
        'p1' => { plant_accession: 'pa', originating_organisation: 'oo' },
        'p2' => { plant_accession: 'pa', originating_organisation: 'oo' },
        'p3' => { plant_accession: 'pa', originating_organisation: 'oo2' },
        'p4' => { plant_accession: 'pa2', originating_organisation: 'oo' }
      }
      mapping = { 0 => 2, 1 => 1, 2 => 0, 3 => 0 }
      replicate_numbers = { 0 => 1, 1 => 1, 2 => 1, 3 => 2 }

      sd.object.submission.content.update(:step02, trait_descriptor_list: traits)
      sd.object.submission.content.update(:step03,
        trait_scores: scores,
        trait_mapping: mapping,
        accessions: accessions,
        replicate_numbers: replicate_numbers
      )
      expect(sd.parser_summary).
        to eq [
          'Uploaded file parsing summary:',
          ' - parsed 4 plant scoring unit(s) with unique identification',
          '  - 2 unit(s) have 2 trait score(s) recorded',
          '  - 1 unit(s) have 1 trait score(s) recorded',
          '  - 1 unit(s) have 0 trait score(s) recorded',
          ' - parsed 3 different accession(s)',
          ' - parsed scores for 4 trait(s), including technical replicates',
          '  - 1 score(s) recorded for trait traitY rep1',
          '  - 1 score(s) recorded for trait traitX rep1',
          '  - 2 score(s) recorded for trait traitZ rep1',
          '  - 1 score(s) recorded for trait traitZ rep2'
        ]
    end
  end
end
