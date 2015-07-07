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
      scores = {
        'p1' => {},
        'p2' => { 1 => 'x' },
        'p3' => { 0 => 'y', 2 => 'z' },
        'p4' => { 2 => '' }
      }
      sd.object.submission.content.update(:step03, trait_scores: scores)
      expect(sd.parser_summary).
        to eq [
          'Uploaded file parsing summary:',
          ' - parsed 4 plant(s) with unique identification',
          ' - 1 plant(s) have 2 trait score(s) recorded',
          ' - 2 plant(s) have 1 trait score(s) recorded',
          ' - 1 plant(s) have 0 trait score(s) recorded'
        ]
    end
  end
end
