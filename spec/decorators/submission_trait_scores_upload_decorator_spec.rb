require 'rails_helper'

RSpec.describe SubmissionTraitScoresUploadDecorator do
  let(:upload) { create(:upload) }
  let(:sd) { described_class.decorate(upload) }

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
        'p4' => { 2 => '' }
      }
      mapping = { 0 => 2, 1 => 1, 2 => 0 }
      sd.object.submission.content.update(:step02, trait_descriptor_list: traits)
      sd.object.submission.content.update(:step04, trait_scores: scores, trait_mapping: mapping)
      expect(sd.parser_summary).
        to eq [
          'Uploaded file parsing summary:',
          ' - parsed 4 plant(s) with unique identification',
          '  - 1 plant(s) have 2 trait score(s) recorded',
          '  - 2 plant(s) have 1 trait score(s) recorded',
          '  - 1 plant(s) have 0 trait score(s) recorded',
          ' - parsed scores for 3 trait(s)',
          '  - 1 score(s) recorded for trait traitY',
          '  - 1 score(s) recorded for trait traitX',
          '  - 2 score(s) recorded for trait traitZ'
        ]
    end
  end
end
