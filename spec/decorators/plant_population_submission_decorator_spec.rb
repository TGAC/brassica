require 'rails_helper'

RSpec.describe PlantPopulationSubmissionDecorator do
  let(:sd) do
    PlantPopulationSubmissionDecorator.decorate(
      create(:submission, submission_type: :population)
    )
  end

  describe '#label' do
    let(:tt) { create(:taxonomy_term) }

    it 'does not throw exception' do
      expect { sd.label }.
        not_to raise_error
    end

    it 'returns proper label' do
      sd.object.content.update(:step01, name: 'pn')
      sd.object.content.update(:step02, taxonomy_term: tt.name)
      expect(sd.label).to eq '<span class="title">pn (' + tt.name + ')</span>'
    end

    it 'returns population name when no taxonomy term' do
      sd.object.content.update(:step01, name: 'pn')
      expect(sd.label).to eq '<span class="title">pn</span>'
    end

    it 'returns taxonomy term when no population name' do
      sd.object.content.update(:step02, taxonomy_term: tt.name)
      expect(sd.label).to eq '<span class="title">(' + tt.name + ')</span>'
    end

    it 'returns empty label when no name or taxonomy term given' do
      expect(sd.label).
        to eq '<span class="title">' +
              I18n.t('submission.empty_label') +
              '</span>'
    end
  end

  describe '#further_details' do
    it 'does not throw exception' do
      expect { sd.further_details }.
          not_to raise_error
    end

    it 'returns full further details info' do
      sd.object.content.update(:step01, population_type: 'pt')
      expect(sd.further_details).to eq '<span class="details">pt</span>'

      sd.object.content.update(:step02, male_parent_line: 'mpl')
      expect(sd.further_details).
        to eq '<span class="details">pt</span>' +
              '<span class="text">Parents: </span>' +
              '<span class="details">mpl</span>'

      sd.object.content.update(:step02, female_parent_line: 'fpl', male_parent_line: 'mpl')
      expect(sd.further_details).
        to eq '<span class="details">pt</span>' +
              '<span class="text">Parents: </span>' +
              '<span class="details">fpl | mpl</span>'
    end
  end
end
