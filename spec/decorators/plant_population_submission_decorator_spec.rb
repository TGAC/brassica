require 'rails_helper'

RSpec.describe PlantPopulationSubmissionDecorator do
  let(:sd) do
    PlantPopulationSubmissionDecorator.decorate(
      create(:submission, submission_type: :population)
    )
  end

  describe '#label' do
    it 'does not throw exception' do
      expect { sd.label }.
        not_to raise_error
    end

    it 'returns proper label' do
      pending 'Cannot test full label without solving #12'
      fail
    end

    it 'returns population name when no species' do
      sd.object.content.update(:step01, name: 'pn')
      expect(sd.label).to eq '<span class="title">pn</span>'
    end

    it 'returns empty label when no name or species given' do
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
      sd.object.content.update(:step02, population_type: 'pt')
      expect(sd.further_details).to eq '<span class="details">pt</span>'

      sd.object.content.update(:step03, male_parent_line: 'mpl')
      expect(sd.further_details).
        to eq '<span class="details">pt</span>' +
              '<span class="text">Parents: </span>' +
              '<span class="details">mpl</span>'

      sd.object.content.update(:step03, female_parent_line: 'fpl', male_parent_line: 'mpl')
      expect(sd.further_details).
        to eq '<span class="details">pt</span>' +
              '<span class="text">Parents: </span>' +
              '<span class="details">fpl | mpl</span>'
    end
  end
end
