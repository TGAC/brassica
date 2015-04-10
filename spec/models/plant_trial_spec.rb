require 'rails_helper'

RSpec.describe PlantTrial do
  describe '#filter' do
    it 'allow queries by project_descriptor' do
      pts = create_list(:plant_trial, 2)
      search = PlantTrial.filter(
          query: { project_descriptor: pts[0].project_descriptor }
      )
      expect(search.count).to eq 1
      expect(search.first).to eq pts[0]
    end

    it 'will only search by permitted params' do
      create(:plant_trial, plant_trial_name: 'ptn')
      search = PlantLine.filter(
          query: { plant_trial_name: 'ptn' }
      )
      expect(search.count).to eq 0
    end
  end

  describe '#pluckable' do
    it 'gets proper data table columns' do
      pt = create(:plant_trial)
      plucked = PlantTrial.pluck_columns
      expect(plucked.count).to eq 1
      expect(plucked[0]).
        to eq [
          pt.plant_trial_name,
          pt.plant_trial_description,
          pt.project_descriptor,
          pt.plant_population.name,
          pt.trial_year,
          pt.trial_location_site_name,
          pt.date_entered,
          pt.id
        ]
    end
  end

  describe '#table_data' do
    it 'orders plant trials by trial year' do
      ptyears = create_list(:plant_trial, 3).map(&:trial_year)
      td = PlantTrial.table_data
      expect(td.map{ |pt| pt[4] }).to eq ptyears.sort
    end
  end
end
