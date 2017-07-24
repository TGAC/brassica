require 'rails_helper'

RSpec.describe "BRAPI V1 phenotypes calls" do
  let(:user) { create(:user) }
  let(:api_key) { user.api_key }
  let(:parsed_response) { JSON.parse(response.body) }


  context 'phenotypes-search' do
    
    let!(:co) { create(:country, country_code: "CHN", country_name: "China") }
    
    let!(:pa) { create(:plant_accession, plant_accession: "hzau2003_TN077_a03") }
    let!(:pt) { create(:plant_trial, plant_trial_name: "hzau_2003_Wuhan_02", country: co) }
    let!(:psu) { create(:plant_scoring_unit, plant_accession: pa, plant_trial: pt) }
    let!(:td) { create(:trait_descriptor, descriptor_name: "seed yield per plant") }
    let!(:ts) { create(:trait_score, plant_scoring_unit: psu, trait_descriptor: td, score_value: 64) }

    let!(:pa2) { create(:plant_accession, plant_accession: "hzau2004_TN038_a02") }
    let!(:pt2) { create(:plant_trial, plant_trial_name: "hzau_2004_Weinan_03", country: co) }
    let!(:psu2) { create(:plant_scoring_unit, plant_accession: pa2, plant_trial: pt2) }
    let!(:td2) { create(:trait_descriptor, descriptor_name: "siliquae of main inflorescence") }
    let!(:ts2) { create(:trait_score, plant_scoring_unit: psu2, trait_descriptor: td2, score_value: 71) }
    let!(:ts23) { create(:trait_score, plant_scoring_unit: psu2, trait_descriptor: td2, score_value: 72) }

    it 'phenotypes-search cheking query by germplasmDbIds = hzau2003_TN077_a03 returns exactly 1 result' do
      headers = { 
        "CONTENT_TYPE" => "application/json",
        "X-BIP-Api-Key" => api_key.token 
      }
      post '/brapi/v1/phenotypes-search', {
        germplasmDbIds: 'hzau2003_TN077_a03'
      }.to_json, headers
      expect(response.status).to eq 200
      expect(parsed_response['result'].size).to eq 1
    end
    
    it 'phenotypes-search cheking query by germplasmDbIds = [hzau2003_TN077_a03, hzau2004_TN038_a02] returns exactly 2 results' do
      headers = { 
        "CONTENT_TYPE" => "application/json",
        "X-BIP-Api-Key" => api_key.token 
      }
      post '/brapi/v1/phenotypes-search', {
        germplasmDbIds: ['hzau2003_TN077_a03','hzau2004_TN038_a02']
      }.to_json, headers
      expect(response.status).to eq 200
      expect(parsed_response['result']['data'].size).to eq 2
    end
    
  
    it 'phenotypes-search cheking ordering: query by germplasmDbIds = [hzau2003_TN077_a03, hzau2004_TN038_a02], 
    sortBy: germplasmDbIds and sortOrder: asc, returns first hzau2003_TN077_a03' do
      headers = { 
        "CONTENT_TYPE" => "application/json",
        "X-BIP-Api-Key" => api_key.token 
      }
      post '/brapi/v1/phenotypes-search', {
        germplasmDbIds: ['hzau2003_TN077_a03','hzau2004_TN038_a02'],
        sortBy: "germplasmDbIds", 
        sortOrder: "asc"
      }.to_json, headers
      expect(response.status).to eq 200
      expect(parsed_response['result']['data'].size).to eq 2
      expect(parsed_response['result']['data'][0]['germplasmDbId']).to eq "hzau2003_TN077_a03"
    end
    
    it 'phenotypes-search cheking ordering: query by germplasmDbIds = [hzau2003_TN077_a03, hzau2004_TN038_a02], 
    sortBy: germplasmDbIds and sortOrder: desc, returns first hzau2004_TN038_a02' do
      headers = { 
        "CONTENT_TYPE" => "application/json",
        "X-BIP-Api-Key" => api_key.token 
      }
      post '/brapi/v1/phenotypes-search', {
        germplasmDbIds: ['hzau2003_TN077_a03','hzau2004_TN038_a02'],
        sortBy: "germplasmDbIds", 
        sortOrder: "desc"
      }.to_json, headers
      expect(response.status).to eq 200
      expect(parsed_response['result']['data'].size).to eq 2
      expect(parsed_response['result']['data'][0]['germplasmDbId']).to eq "hzau2004_TN038_a02"
    end
 
    it 'cheking format' do        
      headers = { 
        "CONTENT_TYPE" => "application/json",
        "X-BIP-Api-Key" => api_key.token 
      }
      post '/brapi/v1/phenotypes-search', {
        germplasmDbIds: 'hzau2003_TN077_a03'
      }.to_json, headers
      expect(response.status).to eq 200
      expect(response.header['Content-Type']).to include 'application/json'
      results = parsed_response['result']
      
      result = results['data'][0]
      
      expect(result['observationUnitDbId']).to be_a String      # mandatory field
      expect(result['studyDbId']).to be_a String                # mandatory field
      expect(result['studyName']).to be_nil.or(be_a String)
      expect(result['studyLocationDbId']).to be_a String        # mandatory field
      expect(result['studyLocation']).to be_nil.or(be_a String)
      expect(result['observationLevel']).to be_nil.or(be_a String)
      expect(result['observationLevels']).to be_nil.or(be_a String)
      expect(result['plotNumber']).to be_nil.or(be_a String)
      expect(result['plantNumber']).to be_nil.or(be_a String)
      expect(result['blockNumber']).to be_nil.or(be_a String)
      expect(result['replicate']).to be_nil.or(be_a String)
      expect(result['programName']).to be_nil.or(be_a String)
      expect(result['germplasmDbId']).to be_a String            # mandatory field

      expect(result['X']).to be_nil.or(be_a String)
      expect(result['Y']).to be_nil.or(be_a String)
      expect(result['treatments']).to be_nil.or(be_a Array)
      expect(result['observationUnitXref']).to be_nil.or(be_a Array)
      observationsXref = result['observationUnitXref']
      if (observationsXref.size > 0)
        observationXref = observationsXref[0]
        
        expect(observationXref).to be_nil.or(be_a Hash)
        expect(observationXref['source']).to be_a String     # mandatory field
        expect(observationXref['id']).to be_a String         # mandatory field

        observationXref.keys.each do |key|
          if (['source','id'].include? key)
            expect(observationXref[key]).to be_nil.or(be_a String)
          else
            raise_error('Unexpected property name: observationXref['+key+']')
          end
        end  
      end
      
      expect(result['observations']).to be_a Array             # mandatory field
    
      observations = result['observations']
      expect(observations.size).to be > 0
      observation = observations[0]
      
      expect(observation).to be_nil.or(be_a Hash)
      expect(observation['observationVariableDbId']).to be_a String     # mandatory field
      observation.keys.each do |key|
        if (['observationDbId','observationVariableName','season','observationTimeStamp',
            'collector','observationVariableDbId'].include? key)
          expect(observation[key]).to be_nil.or(be_a String)
        else
          raise_error('Unexpected property name: observation['+key+']')
        end
      end  

    end     
    
  end
  
end
