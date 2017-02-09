require 'rails_helper'

RSpec.describe PlantPopulation do
  context "associations" do
    it { should have_one(:submission).with_foreign_key(:submitted_object_id).dependent(:destroy) }
  end

  it 'does not need owner for updates' do
    pp = create(:plant_population)
    pp.update_attribute(:user_id, nil)
    pp.canonical_population_name = 'cpn'
    pp.save
    expect(pp.valid?).to be_truthy
    expect(pp.canonical_population_name).to eq 'cpn'
  end

  it 'requires owner for new populations' do
    expect{ create(:plant_population, user: nil) }.
      to raise_error ActiveRecord::RecordInvalid
  end

  it 'assigns publication date when published' do
    pp = build(:plant_population, published: true, published_on: nil)
    expect(pp).to be_valid
    expect(pp.published_on).not_to be_blank
  end

  it 'requires establishing_organisation to not be blank on create' do
    pp = build(:plant_population, establishing_organisation: '')
    expect(pp).to_not be_valid
    pp.establishing_organisation = 'foo'
    expect(pp).to be_valid
  end

  describe '#filter' do
    before(:each) do
      @pp = create(:plant_population)
    end

    it 'will only query by permitted params' do
      search = PlantPopulation.filter(
        query: { published: @pp.published }
      )
      expect(search.count).to eq 0
      search = PlantPopulation.filter(
        query: { id: @pp.id }
      )
      expect(search.count).to eq 1
      expect(search[0].id).to eq @pp.id
    end
  end

  describe '#table_data' do
    it 'returns empty result when no plant population is present' do
      expect(PlantPopulation.table_data).to be_empty
    end

    it 'properly calculates related models number' do
      pls = create_list(:plant_line, 3)
      pps = create_list(:plant_population, 3)
      create_list(:linkage_map, 3, plant_population: pps[1])
      create_list(:linkage_map, 1, plant_population: pps[2])
      create_list(:plant_trial, 2, plant_population: pps[0])
      create_list(:population_locus, 4, plant_population: pps[2])
      create(:plant_population_list, plant_population: pps[0], plant_line: pls[0])
      create(:plant_population_list, plant_population: pps[0], plant_line: pls[1])
      create(:plant_population_list, plant_population: pps[1], plant_line: pls[2])
      create(:plant_population_list, plant_population: pps[1], plant_line: pls[1])
      gd = PlantPopulation.table_data
      expect(gd).not_to be_empty
      expect(gd.size).to eq 3
      expect(gd.map{ |pp| pp[7] }).to contain_exactly 2, 2, 0
      expect(gd.map{ |pp| pp[8] }).to contain_exactly 0, 3, 1
      expect(gd.map{ |pp| pp[9] }).to contain_exactly 2, 0, 0
      expect(gd.map{ |pp| pp[10] }).to contain_exactly 0, 0, 4
    end

    it 'orders populations by population name' do
      ppids = create_list(:plant_population, 3).map(&:name)
      expect(PlantPopulation.table_data.map(&:second)).to eq ppids.sort
    end

    it 'gets proper columns' do
      fpl = create(:plant_line)
      mpl = create(:plant_line)
      pp = create(:plant_population,
                  female_parent_line: fpl,
                  male_parent_line: mpl)

      gd = PlantPopulation.table_data
      expect(gd.count).to eq 1
      data = [
        pp.taxonomy_term.name,
        pp.name,
        pp.canonical_population_name,
        fpl.plant_line_name,
        mpl.plant_line_name,
        pp.population_type.population_type,
        pp.description,
        0, 0, 0, 0,
        fpl.id,
        mpl.id,
        pp.id
      ]
      expect(gd[0]).to eq data
    end

    it 'retrieves published data only' do
      u = create(:user)
      pp1 = create(:plant_population, user: u, published: true)
      pp2 = create(:plant_population, user: u, published: false)

      pl = create(:plant_line, user: u, published: false)
      pp3 = create(:plant_population, male_parent_line: pl, user: u, published: true)

      gd = PlantPopulation.table_data
      expect(gd.count).to eq 2

      gd = PlantPopulation.table_data(nil, u.id)
      expect(gd.count).to eq 3
    end
  end

  describe '#cascade_visibility' do
    it 'changes visibility of all related plant population lists' do
      pp = create(:plant_population, user: create(:user), published: false)
      create_list(:plant_population_list, 2, plant_population: pp, user: pp.user, published: false)

      expect { pp.update_attribute(:published, true) }.
          to change { PlantPopulationList.visible(nil).count }.by(2)
    end

    it 'does nothing when there is no visibility change' do
      expect_any_instance_of(PlantPopulationList).not_to receive(:update_attributes!)
      pp = create(:plant_population, user: create(:user), published: false)
      create(:plant_population_list, plant_population: pp, user: pp.user, published: false)
      pp.update_attribute(:name, 'some other name')
    end
  end

  describe '#submission' do
    it 'is destroyed when the population is destroyed' do
      submission = create(:submission, :population, :finalized)
      expect { submission.submitted_object.destroy }.
        to change { Submission.population.count }.by(-1)
    end
  end
end
