require 'rails_helper'

RSpec.describe PlantTrialSubmissionDecorator do
  let(:sd) do
    PlantTrialSubmissionDecorator.decorate(
      create(:submission, submission_type: :trial)
    )
  end

  describe '#sorted_trait_names' do
    it 'does not throw exception' do
      expect { sd.sorted_trait_names }.
        not_to raise_error
    end

    it 'returns empty array for no-trait submission' do
      expect(sd.sorted_trait_names).to eq []
    end

    it 'works for both old and new traits' do
      tds = create_list(:trait_descriptor, 2)
      sd.object.content.update(:step02, trait_descriptor_list: tds.map(&:id) + ['a new trait'])
      expect(sd.sorted_trait_names).to eq (tds.map{ |td| td.trait.name } + ['a new trait'])
    end
  end
end
