require 'rails_helper'

RSpec.describe PlantTrial do
  it { should belong_to(:plant_population).touch(true) }

  context "validations" do
    it { should validate_presence_of(:plant_trial_name) }
    it { should validate_presence_of(:project_descriptor) }
    it { should validate_presence_of(:trial_year) }
    it { should validate_presence_of(:place_name) }
    it { should validate_numericality_of(:latitude).
          is_greater_than_or_equal_to(-90).
          is_less_than_or_equal_to(90) }
    it { should validate_numericality_of(:longitude).
          is_greater_than_or_equal_to(-180).
          is_less_than_or_equal_to(180) }
  end

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

  describe '#pluck_columns' do
    it 'gets proper data table columns' do
      pt = create(:plant_trial, :with_layout)
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
          pt.country.country_name,
          pt.institute_id,
          pt.layout_file_name,
          pt.id,
          pt.plant_scoring_units.count,
          pt.plant_population.id,
          pt.pubmed_id,
          pt.id
        ]
      expect(plucked[0][8]).to eq 'plant-trial-layout-example.jpg'
    end
  end

  describe '#table_data' do
    it 'retrieves published data only' do
      u = create(:user)
      pt1 = create(:plant_trial, user: u, published: true)
      pt2 = create(:plant_trial, user: u, published: false)

      ptd = PlantTrial.table_data
      expect(ptd.count).to eq 1

      ptd = PlantTrial.table_data(nil, u.id)
      expect(ptd.count).to eq 2
    end
  end

  describe '#scoring_table_data' do
    it 'returns empty table by default' do
      expect(subject.scoring_table_data).to eq []
    end

    context 'when there are PSUs inside the trial' do
      let(:plant_trial) { create(:plant_trial) }
      before(:each) { create_list(:plant_scoring_unit, 3, plant_trial: plant_trial) }

      it 'returns all plant scoring units' do
        scoring_table = plant_trial.scoring_table_data
        expect(scoring_table).
          to eq plant_trial.plant_scoring_units.map{ |psu| [psu.scoring_unit_name, psu.id] }.sort
      end

      context 'and they have trait scores recorded' do
        let(:psus) { plant_trial.plant_scoring_units.order('scoring_unit_name asc') }
        let(:tds) { create_list(:trait_descriptor, 2) }
        let(:replicate_numbers) { { tds[0].id => 1, tds[1].id => 1 } }
        before(:each) do
          create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: psus[0])
          create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: psus[0])
          create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: psus[2])
        end

        it 'provides scores in correct TD order' do
          scoring_table = plant_trial.scoring_table_data
          expect(scoring_table[0][1]).to eq tds[0].trait_scores[0].score_value
          expect(tds[1].trait_scores.map(&:score_value)).to include scoring_table[2][2]
        end

        it 'properly treats sparse data' do
          scoring_table = plant_trial.scoring_table_data
          expect(scoring_table[1][1]).to eq '-'
          expect(scoring_table[1][2]).to eq '-'
          expect(scoring_table[2][1]).to eq '-'
        end

        context 'with technical replicates' do
          let(:replicate_numbers) { { tds[0].id => 3, tds[1].id => 2 } }
          before(:each) do
            create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: psus[0], technical_replicate_number: 2)
            create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: psus[0], technical_replicate_number: 3)
            create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: psus[0], technical_replicate_number: 2)
            create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: psus[2], technical_replicate_number: 2)
          end

          it 'builds proper sparse matrix of values' do
            scoring_table = plant_trial.scoring_table_data

            expect(scoring_table[0][1..3]).to eq tds[0].trait_scores.where(plant_scoring_unit: psus[0]).order(:technical_replicate_number).pluck(:score_value)
            expect(scoring_table[0][4..5]).to eq tds[1].trait_scores.where(plant_scoring_unit: psus[0]).order(:technical_replicate_number).pluck(:score_value)
            expect(scoring_table[1][1..5]).to eq %w(- - - - -)
            expect(scoring_table[2][1]).to eq '-'
            expect(scoring_table[2][2]).to eq TraitScore.find_by(plant_scoring_unit: psus[2], trait_descriptor: tds[0]).score_value
            expect(scoring_table[2][3]).to eq '-'
            expect(scoring_table[2][4]).to eq TraitScore.find_by(plant_scoring_unit: psus[2], trait_descriptor: tds[1]).score_value
            expect(scoring_table[2][5]).to eq '-'
          end
        end
      end
    end
  end

  describe '#replicate_numbers' do
    let(:plant_trial) { create(:plant_trial) }
    let(:ps) { create(:plant_scoring_unit, plant_trial: plant_trial) }
    let(:tds) { create_list(:trait_descriptor, 2) }
    before(:each) do
      create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: ps, technical_replicate_number: 2)
      create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: ps, technical_replicate_number: 3)
      create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: ps, technical_replicate_number: 2)
    end

    it 'returns empty hash if no scores are present' do
      expect(subject.replicate_numbers).to eq({})
    end

    it 'groups technical replicate numbers by trait descriptor id' do
      expect(plant_trial.replicate_numbers).
        to eq({ tds[0].id => 3, tds[1].id => 2 })
    end
  end

  it 'destroys plant scoring units when parent object is destroyed' do
    psu = create(:plant_scoring_unit)
    ptr = create(:plant_trial, plant_scoring_units: [psu])
    expect { ptr.destroy }.to change { PlantScoringUnit.count }.by(-1)
  end
end
