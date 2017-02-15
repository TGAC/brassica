require "rails_helper"

RSpec.describe Submission::PlantPopulationExporter do
  let(:submission) { create(:finalized_submission, :population, published: true) }
  let(:plant_population) { submission.submitted_object }
  let(:plant_lines) { create_list(:plant_line, 2, plant_variety: create(:plant_variety)) }

  subject { described_class.new(submission) }

  describe "#documents" do
    it 'produces properly formatted all plant submission CSV documents' do
      create(:plant_population_list, plant_line: plant_lines[0],
                                     plant_population: plant_population)
      create(:plant_population_list, plant_line: plant_lines[1],
                                     plant_population: plant_population)
      male_parent_line = create(:plant_line, fathered_descendants: [plant_population],
                                             plant_variety: create(:plant_variety))
      female_parent_line = create(:plant_line, mothered_descendants: [plant_population],
                                               plant_variety: create(:plant_variety))

      documents = subject.documents

      expect(documents.size).to eq 5
      expect(documents[:plant_population].lines.size).to eq 2
      expect(documents[:plant_population].lines[1].chomp).
        to end_with plant_population.establishing_organisation
      expect(documents[:plant_varieties].lines.size).to eq 4
      expect(documents[:plant_varieties].lines[1,3].map{ |l| l.split(',')[0] }).
        to match_array PlantVariety.all.pluck(:plant_variety_name)
      expect(documents[:plant_lines].lines.size).to eq 3
      expect(documents[:plant_lines].lines[1,2].map{ |l| l.split(',')[1] }).
        to match_array plant_lines.map(&:plant_line_name)
      expect(documents[:female_parent_line].lines.size).to eq 2
      expect(documents[:female_parent_line].lines[1].split(',')[1]).
        to eq female_parent_line.plant_line_name
      expect(documents[:male_parent_line].lines.size).to eq 2
      expect(documents[:male_parent_line].lines[1].split(',')[1]).
        to eq male_parent_line.plant_line_name
    end

    it 'produces no documents for no-data cases' do
      documents = subject.documents
      expect(documents.size).to eq 1
    end

    it 'handles commas appropriately' do
      plant_population.update_attribute(:name, 'With,comma')
      documents = subject.documents
      expect(documents.size).to eq 1
      expect(documents[:plant_population].lines.size).to eq 2
      expect(documents[:plant_population].lines[1]).
        to include '"With,comma"'
    end

    it 'exports plant varieties for parent lines in absence of population lists' do
      create(:plant_line, fathered_descendants: [plant_population],
                          plant_variety: create(:plant_variety))
      documents = subject.documents
      expect(documents.size).to eq 3
      expect(documents[:plant_varieties].lines.size).to eq 2
      expect(documents[:plant_lines]).to be_nil
      expect(documents[:male_parent_line].lines.size).to eq 2
    end


    it 'uses localized column headers' do
      create(:plant_population_list, plant_line: plant_lines[0],
                                     plant_population: plant_population)
      create(:plant_line, fathered_descendants: [plant_population],
                          plant_variety: create(:plant_variety))
      create(:plant_line, mothered_descendants: [plant_population],
                          plant_variety: create(:plant_variety))

      documents = subject.documents

      expect(documents.size).to eq 5
      expect(documents[:plant_population].lines[0].strip.split(',')).
        to eq [
          I18n.t('tables.taxonomy_terms.name'),
          I18n.t('tables.plant_populations.name'),
          I18n.t('tables.plant_populations.canonical_population_name'),
          I18n.t('tables.plant_populations.female_parent_line'),
          I18n.t('tables.plant_populations.male_parent_line'),
          I18n.t('tables.pop_type_lookup.population_type'),
          I18n.t('tables.plant_populations.description'),
          I18n.t('tables.plant_populations.establishing_organisation')
        ]

      expect(documents[:plant_varieties].lines[0].strip.split(',')).
        to eq [
          I18n.t('tables.plant_varieties.plant_variety_name'),
          I18n.t('tables.plant_varieties.crop_type'),
          I18n.t('tables.plant_varieties.data_attribution'),
          I18n.t('tables.plant_varieties.year_registered'),
          I18n.t('tables.plant_varieties.breeders_variety_code'),
          I18n.t('tables.plant_varieties.owner'),
          I18n.t('tables.plant_varieties.quoted_parentage'),
          I18n.t('tables.plant_varieties.female_parent'),
          I18n.t('tables.plant_varieties.male_parent')
        ]

      plant_line_columns = [
        I18n.t('tables.taxonomy_terms.name'),
        I18n.t('tables.plant_lines.plant_line_name'),
        I18n.t('tables.plant_lines.common_name'),
        I18n.t('tables.plant_varieties.plant_variety_name'),
        I18n.t('tables.plant_lines.previous_line_name'),
        I18n.t('tables.plant_lines.genetic_status'),
        I18n.t('tables.plant_lines.sequence_identifier'),
        I18n.t('tables.plant_lines.data_owned_by'),
        I18n.t('tables.plant_lines.organisation')
      ]

      expect(documents[:plant_lines].lines[0].strip.split(',')).
        to eq plant_line_columns

      expect(documents[:male_parent_line].lines[0].strip.split(',')).
        to eq plant_line_columns

      expect(documents[:female_parent_line].lines[0].strip.split(',')).
        to eq plant_line_columns
    end
  end
end
