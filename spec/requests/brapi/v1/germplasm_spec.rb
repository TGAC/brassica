require 'rails_helper'

RSpec.describe "BRAPI V1 germplasm calls" do
  let(:user) { create(:user) }
  let(:api_key) { user.api_key }
  let(:parsed_response) { JSON.parse(response.body) }


  context 'germplasm-search' do    
    let!(:pl) { create(:plant_line, published: true, user: user) }
    let!(:pp) { create(:plant_population, name: 'test', establishing_organisation: 'test', published: true, user: user) }
    let!(:ppl) { create(:plant_population_list, plant_population: pp, plant_line: pl, published: true, user: user) }
    let!(:pa) { create(:plant_accession, plant_line: pl, plant_accession: "hzau2003_TN077_a03", published: true, user: user) }


    it 'requires at least one valid search param (germplasmPUI, germplasmDbId,or germplasmName ) to work' do
      headers = { 
        "CONTENT_TYPE" => "application/json"
      }
      
      get '/brapi/v1/germplasm-search?wrongParameter=hzau2003_TN077_a03', {}, headers
      expect(response.status).to eq 422
      
      get '/brapi/v1/germplasm-search?germplasmDbId=hzau2003_TN077_a03', {}, headers
      expect(response.status).to eq 200
      
      get '/brapi/v1/germplasm-search?germplasmName=hzau2003_TN077_a03', {}, headers
      expect(response.status).to eq 200
      
      get '/brapi/v1/germplasm-search?germplasmDbId=hzau2003_TN077_a03&germplasmName=oneNotValid', {}, headers
      expect(response.status).to eq 404
      
    end
    
    it 'cheking query by germplasmDbId = hzau2003_TN077_a03 returns exactly 1 result' do 
      headers = { 
        "CONTENT_TYPE" => "application/json"
      }
      
      get '/brapi/v1/germplasm-search?germplasmDbId=hzau2003_TN077_a03', {}, headers
      expect(response.status).to eq 200
      expect(parsed_response['result'].size).to eq 1
      
    end
    
    it 'cheking query by germplasmDbId = hzau2003_TN077_a04 returns not acessible/found dataset' do        
      get '/brapi/v1/germplasm-search?germplasmDbId=hzau2003_TN077_a04', {}, headers
      expect(response.status).to eq 404
      
    end     
    
    it 'cheking format' do        
      get '/brapi/v1/germplasm-search?germplasmDbId=hzau2003_TN077_a03', {}, headers
      expect(response.status).to eq 200
      expect(response.header['Content-Type']).to include 'application/json'
      result = parsed_response['result']
      expect(result['data'][0]['germplasmDbId']).to be_nil.or(be_a String)
      expect(result['data'][0]['defaultDisplayName']).to be_nil.or(be_a String)
      expect(result['data'][0]['accessionNumber']).to be_nil.or(be_a String)
      expect(result['data'][0]['commonCropName']).to be_nil.or(be_a String)
      expect(result['data'][0]['instituteCode']).to be_nil.or(be_a String)
      expect(result['data'][0]['instituteName']).to be_nil.or(be_a String)
      expect(result['data'][0]['biologicalStatusOfAccessionCode']).to be_nil.or(be_a String)
      expect(result['data'][0]['countryOfOriginCode']).to be_nil.or(be_a String)
      expect(result['data'][0]['genus']).to be_nil.or(be_a String)
      expect(result['data'][0]['species']).to be_nil.or(be_a String)
      expect(result['data'][0]['subtaxa']).to be_nil.or(be_a String)
      
    end     
       
  end
  
  
end
