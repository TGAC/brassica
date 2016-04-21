require 'rails_helper'

RSpec.describe DataTablesController do
  context 'when unauthenticated' do
    describe '#index' do
      it 'requires model param to work' do
        expect{ get(:index) }.
          to raise_error ActionController::ParameterMissing
        expect{ get(:index, format: :json) }.
          to raise_error ActionController::ParameterMissing
      end

      it 'prevents getting model that is not permitted' do
        expect{ get(:index, model: 'unpermitted_models') }.
          to raise_error ActionController::RoutingError
        expect{ get(:index, format: :json, model: 'unpermitted_models') }.
          to raise_error ActionController::RoutingError
      end

      it 'returns table template on html format request' do
        DataTablesController.new.send('allowed_models').each do |model|
          get :index, model: model
          expect(response).to render_template("data_tables/index")
          expect(response).to render_template('layouts/application')
        end
      end

      it 'does not raise error on wrong parameter json format request' do
        get :index,
            format: :json,
            model: 'plant_lines',
            query: { plant_line_name: 'wrong!' }
        expect(response).to have_http_status(:success)
      end

      it 'does not render htmls on json format request' do
        get :index, format: :json, model: 'plant_populations'
        expect(response).not_to render_template('data_tables/index')
        expect(response).not_to render_template('layouts/application')
      end

      it 'returns datatables json on json format request' do
        pps = create_list(:plant_population, 2)
        get :index, format: :json, model: 'plant_populations'
        expect(response.content_type).to eq 'application/json'
        json = JSON.parse(response.body)
        expect(json['recordsTotal']).to eq 2
        expect(json['data'].size).to eq 2
        expect(json['data'].map(&:last)).to match_array pps.map(&:id)
      end

      it 'supports query filtering on json format request' do
        pps = create_list(:plant_population, 2).map(&:id)
        get :index,
            format: :json,
            model: 'plant_populations',
            query: { id: pps[0] }
        expect(response.content_type).to eq 'application/json'
        json = JSON.parse(response.body)
        expect(json['recordsTotal']).to eq 1
        expect(json['data'].size).to eq 1
        expect(json['data'][0][-1]).to eq pps[0]
      end

      it 'prevents querying by unpermitted parameters' do
        create(:plant_line, named_by_whom: 'nbw')
        get :index,
            format: :json,
            model: 'plant_lines',
            query: { named_by_whom: 'nbw' }
        json = JSON.parse(response.body)
        expect(json['recordsTotal']).to eq 0
        expect(json['data'].size).to eq 0
        expect(json['data']).to eq []
      end

      context 'when using cache' do
        before(:each) { Rails.cache.clear }

        it 'caches response when nothing new happened' do
          expect(PlantLine).to receive(:table_data).once.and_return([])
          get :index, format: :json, model: 'plant_lines'
          get :index, format: :json, model: 'plant_lines'
        end

        it 'refreshes cache when a new object appears' do
          expect(PlantLine).to receive(:table_data).twice.and_return([])
          get :index, format: :json, model: 'plant_lines'
          create(:plant_line)
          get :index, format: :json, model: 'plant_lines'
        end

        it 'refreshes cache when a belongs_to related object disappears' do
          pp = create(:plant_population, male_parent_line: nil)
          pp.update_column(:updated_at, Time.now - 5.seconds)
          expect(PlantPopulation).to receive(:table_data).twice.and_call_original
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][3]).to eq PlantLine.first.plant_line_name
          PlantLine.first.destroy
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][3]).to be_nil
        end

        it 'refreshes cache when a belongs_to related object changes' do
          pp = create(:plant_population, male_parent_line: nil)
          pp.update_column(:updated_at, Time.now - 5.seconds)
          expect(PlantPopulation).to receive(:table_data).twice.and_call_original
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][3]).to eq PlantLine.first.plant_line_name
          PlantLine.first.update_attribute :published, false
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][3]).to be_nil
        end

        it 'refreshes cache when a has_many related object is destroyed' do
          pt = create(:plant_trial)
          pt.plant_population.update_column(:updated_at, Time.now - 5.seconds)
          expect(PlantPopulation).to receive(:table_data).twice.and_call_original
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 1
          pt.destroy
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 0
        end

        it "refreshes cache when a has_many related object is created" do
          pp = create(:plant_population)
          pp.update_column(:updated_at, Time.now - 5.seconds)

          expect(PlantPopulation).to receive(:table_data).twice.and_call_original

          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 0

          create(:plant_trial, plant_population: pp)

          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 1
        end

        it 'refreshes cache when a has_many related object is made private' do
          pt = create(:plant_trial, published: true)
          pt.plant_population.update_column(:updated_at, Time.now - 5.seconds)
          expect(PlantPopulation).to receive(:table_data).twice.and_call_original
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 1

          pt.update_attributes!(published: false, published_on: nil)

          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 0
        end

        it 'refreshes cache when a has_many related object is published' do
          pt = create(:plant_trial, published: false)
          pt.plant_population.update_column(:updated_at, Time.now - 5.seconds)
          expect(PlantPopulation).to receive(:table_data).twice.and_call_original
          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 0

          pt.update_attributes!(published: true, published_on: Time.now)

          get :index, format: :json, model: 'plant_populations'
          json = JSON.parse(response.body)
          expect(json['recordsTotal']).to eq 1
          expect(json['data'][0][-5]).to eq 1
        end
      end
    end

    describe '#show' do
      it 'escapes annotation values' do
        pp = create(:plant_population, comments: 'This is <b>HTML</b>')
        get :show,
            id: pp.id,
            format: :json,
            model: 'plant_populations'
        expect(response.body).not_to include '<b>'
        expect(response.body).to include '\\u003cb\\u003eHTML\\u003c/b\\u003e'
      end
    end
  end

  context 'when authenticated' do
    let(:u1) { create :user }
    let(:u2) { create :user }

    before { sign_in u1 }

    describe '#index' do
      it 'returns datatables json on json format request' do
        pp1 = create(:plant_population, published: true, user: u2)
        pp2 = create(:plant_population, published: false, user: u1)
        pp3 = create(:plant_population, published: false, user: u2)

        get :index, format: :json, model: 'plant_populations'
        expect(response.content_type).to eq 'application/json'
        json = JSON.parse(response.body)

        expect(json['recordsTotal']).to eq 2
        expect(json['data'].size).to eq 2
        expect(json['data'].map(&:last)).to match_array [pp1, pp2].map(&:id)
      end

      context 'when using cache' do
        before(:each) { Rails.cache.clear }

        it 'uses different cache key for different user' do
          expect(PlantLine).to receive(:table_data).thrice.and_return([])
          get :index, format: :json, model: 'plant_lines'
          sign_out u1
          get :index, format: :json, model: 'plant_lines'
          sign_in u2
          get :index, format: :json, model: 'plant_lines'
        end
      end
    end
  end
end
