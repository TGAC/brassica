require 'rails_helper'
require 'pp'

RSpec.describe Brapi::V1::GermplasmController do
  
  # BrAPI doesn't use ORCID authentication system and WP7 hasn't agreed yet on an alternative. 
  # We will have to work for some time without requiring authentications.
  #
  #context 'when unauthenticated' do
  #  describe '#search' do
  #
  #    it 'withouth being authenticated you cannot obtain authorithation to do anything' do
  #      get :search , germplasmDbId: 'hzau2003_TN077_a03'
  #        expect(response).to have_http_status(401)
  #    end 
  #  end
  #
  #end
  
  context 'BrAPI without requiring authentication' do
    let(:u1) { create :user }
    before { sign_in u1 }
    
    describe '#search' do

      it 'requires at least one valid search param (germplasmPUI, germplasmDbId,or germplasmName ) to work' do
        pl1 = create(:plant_line, published: true, user: u1)
        pp1 = create(:plant_population, name: 'test', establishing_organisation: 'test', published: true, user: u1)
        ppl1 = create(:plant_population_list, plant_population: pp1, plant_line: pl1, published: true, user: u1)
        pa1 = create(:plant_accession, plant_line: pl1, plant_accession: "hzau2003_TN077_a03", published: true, user: u1)
        
        
        get :search,
            wrongParameter: 'hzau2003_TN077_a03'
        expect(response).to have_http_status(422)
        
        get :search,
            germplasmDbId: 'hzau2003_TN077_a03'
        expect(response).to have_http_status(200)
        
        get :search,
            germplasmName: 'hzau2003_TN077_a03'
        expect(response).to have_http_status(200)
        
        get :search,
            germplasmDbId: 'hzau2003_TN077_a03',
            germplasmName: 'oneNotValid'
        expect(response).to have_http_status(404)
         
      end

      it 'cheking query by germplasmDbId = hzau2003_TN077_a03 returns exactly 1 result' do
        pl1 = create(:plant_line, published: true, user: u1)
        pp1 = create(:plant_population, name: 'test', establishing_organisation: 'test', published: true, user: u1)
        ppl1 = create(:plant_population_list, plant_population: pp1, plant_line: pl1, published: true, user: u1)
        pa1 = create(:plant_accession, plant_line: pl1, plant_accession: "hzau2003_TN077_a03", published: true, user: u1)
        
        get :search,
          format: :json,
          germplasmDbId: "hzau2003_TN077_a03"
          expect(response).to have_http_status(200)
          expect((JSON.parse(response.body))['result'].size).to eq 1
        
      end
      
      it 'cheking query by germplasmDbId = hzau2003_TN077_a04 returns not acessible/found dataset' do        
        pl1 = create(:plant_line, published: false, user: u1)
        pp1 = create(:plant_population, name: 'test', establishing_organisation: 'test', published: false, user: u1)
        ppl1 = create(:plant_population_list, plant_population: pp1, plant_line: pl1, published: false, user: u1)
        pa1 = create(:plant_accession, plant_line: pl1, plant_accession: "hzau2003_TN077_a04", published: false, user: u1)
        
        get :search,
          format: :json,
          germplasmDbId: "hzau2003_TN077_a04"
          expect(response).to have_http_status(404)
        #
        #json = JSON.parse(response.body)
        #expect(json['result'].size).to eq 1

      end
      
 
    end

    before { sign_out u1 }

  end

end
