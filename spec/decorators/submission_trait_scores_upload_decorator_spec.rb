require 'rails_helper'

RSpec.describe SubmissionTraitScoresUploadDecorator do
  let(:upload) { create(:upload) }
  let(:sd) { described_class.decorate(upload) }
  let(:existing_accession) { create(:plant_accession) }
  let(:existing_line) { create(:plant_line) }
  let(:existing_variety) { create(:plant_variety) }

  describe '#parser_summary' do
    it 'does not misbehave on null input' do
      expect(sd.parser_summary).
        to eq ["Uploaded file parsing summary:", " - parsed 0 plant scoring unit(s) with unique identification", " - parsed scores for 0 trait(s), including technical replicates"]
    end

    it 'calculates proper histogram' do
      traits = ['traitZ', 'traitX', 'traitY']
      scores = {
        'p1' => {},
        'p2' => { 1 => 'x' },
        'p3' => { 0 => 'y', 2 => 'z' },
        'p4' => { 2 => '', 3 => 'r' },
        'p5' => {},
        'p6' => {},
        'p7' => {}
      }
      accessions = {
        'p1' => { plant_accession: existing_accession.plant_accession,
                  originating_organisation: existing_accession.originating_organisation },
        'p2' => { plant_accession: 'pa', originating_organisation: 'oo' },
        'p3' => { plant_accession: 'pa', originating_organisation: 'oo2', year_produced: "unknown" },
        'p4' => { plant_accession: 'pa2', originating_organisation: 'oo' },
        'p5' => { plant_accession: existing_accession.plant_accession,
                  originating_organisation: existing_accession.originating_organisation },
        'p6' => { plant_accession: existing_accession.plant_accession,
                  originating_organisation: existing_accession.originating_organisation },
        'p7' => { plant_accession: 'pa2', originating_organisation: 'oo' }
      }
      mapping = { 0 => 2, 1 => 1, 2 => 0, 3 => 0 }
      replicate_numbers = { 0 => 1, 1 => 1, 2 => 1, 3 => 2 }
      lines_or_varieties = {
        'p1' => { relation_class_name: 'PlantVariety', relation_record_name: 'Variety not to be created' },
        'p2' => { relation_class_name: 'PlantVariety', relation_record_name: 'Variety to be created' },
        'p3' => { relation_class_name: 'PlantVariety', relation_record_name: existing_variety.plant_variety_name },
        'p4' => { relation_class_name: 'PlantLine', relation_record_name: existing_line.plant_line_name },
        'p5' => { relation_class_name: 'PlantLine', relation_record_name: 'Line not to be created nor submitted' },
        'p6' => { relation_class_name: 'PlantLine', relation_record_name: existing_line.plant_line_name },
        'p7' => { relation_class_name: 'PlantLine', relation_record_name: 'Line to be submitted' }
      }

      sd.object.submission.content.update(:step02, trait_descriptor_list: traits)
      sd.object.submission.content.update(:step04,
        trait_scores: scores,
        trait_mapping: mapping,
        accessions: accessions,
        replicate_numbers: replicate_numbers,
        lines_or_varieties: lines_or_varieties
      )
      expect(sd.parser_summary).
        to eq [
          'Uploaded file parsing summary:',
          ' - parsed 7 plant scoring unit(s) with unique identification',
          '   - 2 unit(s) have 2 trait score(s) recorded',
          '   - 1 unit(s) have 1 trait score(s) recorded',
          '   - 4 unit(s) have 0 trait score(s) recorded',
          ' - parsed 4 different accession(s)',
          '   - out of which, 1 accession(s) are present in BIP,',
          '   - and 3 new accession(s) will be created, for which',
          '     - 1 existing plant line(s) will be assigned',
          '     - 1 existing plant variety(ies) will be assigned,',
          '     - 1 new plant variety(ies) will be created.',
          ' - parsed scores for 4 trait(s), including technical replicates',
          '   - 1 score(s) recorded for trait traitY rep1',
          '   - 1 score(s) recorded for trait traitX rep1',
          '   - 2 score(s) recorded for trait traitZ rep1',
          '   - 1 score(s) recorded for trait traitZ rep2',
          'There were detected 1 new plant line(s) assigned to new plant accession(s).',
        ]
      expect(sd.parser_warnings).
        to eq [
          "This submission cannot be concluded before the following new plant line(s)",
          "are successfully submitted, using the Population submission procedure:",
          "  - Line to be submitted",
          "\n",
          "This submission cannot be concluded because the following new accessions cannot be created:",
          "  - pa"
        ]
    end
  end
end
