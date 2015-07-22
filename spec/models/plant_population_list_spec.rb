require 'rails_helper'

RSpec.describe PlantPopulationList do
  it 'does not allow duplicate records' do
    pp = create(:plant_population)
    pl = create(:plant_line)

    ppl1 = create(:plant_population_list, plant_population: pp, plant_line: pl)
    expect(ppl1.valid?).to be_truthy

    ppl2 = PlantPopulationList.new(plant_population: pp, plant_line: pl)
    expect(ppl2.valid?).to be_falsey
  end
end
