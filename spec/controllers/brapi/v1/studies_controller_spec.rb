require 'rails_helper'
require 'pp'

RSpec.describe Brapi::V1::StudiesController do
  
  context 'BrAPI without requiring authentication' do
    let(:u1) { create :user }
    before { sign_in u1 }
    
    describe '#search' do

      it 'requires at least one valid param to work' do
      
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial, plant_trial_name: "hzau_2003_Wuhan_02")
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        post :search,
            wrongParameter: 'hzau_2003_Wuhan_02'
        expect(response).to have_http_status(422)
        
        post :search,
            studyNames: 'hzau_2003_Wuhan_02'
        expect(response).to have_http_status(200)
        
        post :search,
            germplasmDbIds: 'hzau2003_TN077_a03'
        expect(response).to have_http_status(200)
        
        post :search,
            germplasmDbId: 'hzau2003_TN077_a03',
            studyNames: 'oneNotValid'
        expect(response).to have_http_status(404)
         
      end
      
      it 'cheking query by germplasmDbId = hzau2003_TN077_a03 returns exactly 1 result' do
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial, plant_trial_name: "hzau_2003_Wuhan_02")
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        post :search,
            germplasmDbIds: 'hzau2003_TN077_a03'
        expect(response).to have_http_status(200)
        expect((JSON.parse(response.body))['result'].size).to eq 1
        
      end

      it 'cheking query by germplasmDbId = [hzau2003_TN077_a03, hzau2004_TN038_a02] returns exactly 2 results' do
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial, plant_trial_name: "hzau_2003_Wuhan_02")
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        pa2 = create(:plant_accession, plant_accession: "hzau2004_TN038_a02")
        pt2 = create(:plant_trial, plant_trial_name: "hzau_2004_Weinan_03")
        psu2 = create(:plant_scoring_unit, plant_accession: pa2, plant_trial: pt2)
        
        post :search,
            germplasmDbIds: ['hzau2003_TN077_a03','hzau2004_TN038_a02']
        expect(response).to have_http_status(200)
        expect((JSON.parse(response.body))['result'].size).to eq 2
        
      end
      
      it 'cheking query by germplasmDbId = [hzau2003_TN077_a03, hzau2004_TN038_a02] 
      and studyLocations: [China] returns exactly 2 results' do
        co = create(:country, country_code: "CHN", country_name: "China")
      
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial, plant_trial_name: "hzau_2003_Wuhan_02", country: co)
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        pa2 = create(:plant_accession, plant_accession: "hzau2004_TN038_a02")
        pt2 = create(:plant_trial, plant_trial_name: "hzau_2004_Weinan_03", country: co)
        psu2 = create(:plant_scoring_unit, plant_accession: pa2, plant_trial: pt2)
        
        post :search,
            germplasmDbIds: ['hzau2003_TN077_a03','hzau2004_TN038_a02'], studyLocations: ['China']
        expect(response).to have_http_status(200)
        expect((JSON.parse(response.body))['result'].size).to eq 2
        
      end
      
      it 'cheking ordering: query by germplasmDbId = [hzau2003_TN077_a03, hzau2004_TN038_a02], 
      sortBy: name and sortOrder: asc,  returns first hzau2003_TN077_a03' do
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial, plant_trial_name: "hzau_2003_Wuhan_02")
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        pa2 = create(:plant_accession, plant_accession: "hzau2004_TN038_a02")
        pt2 = create(:plant_trial, plant_trial_name: "hzau_2004_Weinan_03")
        psu2 = create(:plant_scoring_unit, plant_accession: pa2, plant_trial: pt2)
        
        post :search,
            germplasmDbIds: ['hzau2003_TN077_a03','hzau2004_TN038_a02'], sortBy: "name", sortOrder: "asc"
        expect(response).to have_http_status(200)
        expect((JSON.parse(response.body))['result'][0]['plant_accession']).to eq "hzau2003_TN077_a03"
        
      end
      
      it 'cheking ordering: query by germplasmDbId = [hzau2003_TN077_a03, hzau2004_TN038_a02], 
      sortBy: name and sortOrder: desc,  returns first hzau2004_TN038_a02' do
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial, plant_trial_name: "hzau_2003_Wuhan_02")
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        pa2 = create(:plant_accession, plant_accession: "hzau2004_TN038_a02")
        pt2 = create(:plant_trial, plant_trial_name: "hzau_2004_Weinan_03")
        psu2 = create(:plant_scoring_unit, plant_accession: pa2, plant_trial: pt2)
        
        post :search,
            germplasmDbIds: ['hzau2003_TN077_a03','hzau2004_TN038_a02'], sortBy: "name", sortOrder: "desc"
        expect(response).to have_http_status(200)
        expect((JSON.parse(response.body))['result'][0]['plant_accession']).to eq "hzau2004_TN038_a02"
        
      end
 
    end
    
    
    
    
    describe '#shown' do
    
      it 'requires one valid param to work, id' do
        co = create(:country, country_code: "CHN", country_name: "China")
        
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial , :with_layout, plant_trial_name: "hzau_2003_Wuhan_02", country: co)
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        get :shown
        expect(response).to have_http_status(422)

        get :shown, 
            id: pt.id
        expect(response).to have_http_status(200)
        
        get :shown,
            id: '9999999'
        expect(response).to have_http_status(404)
         
      end
      
      it 'cheking query by id retrieves exactly 1 result' do
        co = create(:country, country_code: "CHN", country_name: "China")
        
        pa = create(:plant_accession, plant_accession: "hzau2003_TN077_a03")
        pt = create(:plant_trial , :with_layout, plant_trial_name: "hzau_2003_Wuhan_02", country: co)
        psu = create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt)
        
        get :shown, 
            id: pt.id
        expect(response).to have_http_status(200)
        expect((JSON.parse(response.body))['result'].size).to eq 1
         
      end
      
      
    end
    

    before { sign_out u1 }

  end

end
