require 'rails_helper'

RSpec.describe PlantScoringUnit do
  describe '#pluck_columns' do
    it 'gets proper data table columns' do
      psc = create(:plant_scoring_unit)
      plucked = PlantScoringUnit.pluck_columns
      expect(plucked.count).to eq 1
      expect(plucked[0]).
        to eq [
          psc.scoring_unit_name,
          psc.number_units_scored,
          psc.scoring_unit_sample_size,
          psc.scoring_unit_frame_size,
          psc.date_planted,
          psc.plant_trial.plant_trial_name,
          psc.plant_part.plant_part,
          psc.plant_accession.plant_accession,
          psc.trait_scores_count,
          psc.plant_accession.id,
          psc.plant_trial.id,
          psc.id
        ]
    end
  end

  it 'destroys trait scores when parent object is destroyed' do
    ts = create(:trait_score)
    t = create(:plant_scoring_unit, trait_scores: [ts])
    expect { t.destroy }.to change { TraitScore.count }.by(-1)
  end

end
