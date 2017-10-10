require 'rails_helper'

RSpec.describe "BRAPI V1 variables calls" do
  let(:user) { create(:user) }
  let(:api_key) { user.api_key }
  let(:parsed_response) { JSON.parse(response.body) }


  context 'list' do    
   
    let!(:t) { create(:trait, data_provenance: "CROPSTORE", label: "CROPSTORE") }
    let!(:pp) { create(:plant_part, plant_part: "average of blocks") }
    let!(:td) { create(:trait_descriptor, descriptor_name: "seed yield per plant", trait: t, plant_part: pp) }
    
    
    it 'cheking variables/list query returns exactly 1 result' do 
      headers = { 
        "CONTENT_TYPE" => "application/json"
      }
      
      get '/brapi/v1/variables', {}, headers
      expect(response.status).to eq 200
      expect(parsed_response['result']['data'].size).to eq 1
      
    end
    
    # TODO: When traitClass param is supported, it will need more tests
    
    
    it 'cheking format' do        
      get '/brapi/v1/variables', {}, headers
      expect(response.status).to eq 200
      expect(response.header['Content-Type']).to include 'application/json'
      result = parsed_response['result']
      
      first_result = result['data'][0]
      expect(first_result['observationVariableDbId']).to be_a String
      expect(first_result['name']).to be_a String
      expect(first_result['ontologyDbId']).to be_nil.or(be_a String)
      expect(first_result['ontologyName']).to be_nil.or(be_a String)
      expect(first_result['synonyms']).to be_nil.or(be_a Array)
      expect(first_result['contextOfUse']).to be_nil.or(be_a Array)      
      expect(first_result['growthStage']).to be_nil.or(be_a String)
      expect(first_result['status']).to be_nil.or(be_a String)
      expect(first_result['xref']).to be_nil.or(be_a String)
      expect(first_result['institution']).to be_nil.or(be_a String)
      expect(first_result['scientist']).to be_nil.or(be_a String)
      expect(first_result['submissionTimestamp']).to be_nil.or(be_a String)
      expect(first_result['language']).to be_nil.or(be_a String)
      expect(first_result['crop']).to be_nil.or(be_a String)
      expect(first_result['defaultValue']).to be_nil.or(be_a String)

      expect(first_result['trait']).to be_nil.or(be_a Hash)
      traits = first_result['trait']
      if (!traits.nil? && traits.size > 0)
        expect(traits['traitDbId']).to be_nil.or(be_a String)
        expect(traits['name']).to be_nil.or(be_a String)
        expect(traits['class']).to be_nil.or(be_a String)
        expect(traits['description']).to be_nil.or(be_a String)
        expect(traits['synonyms']).to be_nil.or(be_a Array)
        expect(traits['mainAbbreviation']).to be_nil.or(be_a String)
        expect(traits['entity']).to be_nil.or(be_a String)
        expect(traits['attribute']).to be_nil.or(be_a String)
        expect(traits['status']).to be_nil.or(be_a String)
        expect(traits['xref']).to be_nil.or(be_a String)
      end

      expect(first_result['method']).to be_nil.or(be_a Hash)
      methods = first_result['method']
      if (!methods.nil? && methods.size > 0)
        expect(methods['methodDbId']).to be_nil.or(be_a String)
        expect(methods['name']).to be_nil.or(be_a String)
        expect(methods['class']).to be_nil.or(be_a String)
        expect(methods['description']).to be_nil.or(be_a String)
        expect(methods['formula']).to be_nil.or(be_a String)
        expect(methods['reference']).to be_nil.or(be_a String)        
      end

      expect(first_result['scale']).to be_nil.or(be_a Hash)
      scales = first_result['scale']
      if (!scales.nil? && scales.size > 0)
        expect(scales['scaleDbId']).to be_nil.or(be_a String)
        expect(scales['name']).to be_nil.or(be_a String)
        expect(scales['datatype']).to be_nil.or(be_a String)
        expect(scales['decimalPlaces']).to be_nil.or(be_a Integer)
        expect(scales['xref']).to be_nil.or(be_a String)
        expect(scales['validValues']).to be_nil.or(be_a Array)   
        validValues = scales['validValues']
        if (!validValues.nil? && validValues.size > 0)
          validValue = validValues[0]  
          expect(validValue['min']).to be_nil.or(be_a Integer)
          expect(validValue['max']).to be_nil.or(be_a Integer) 
          expect(validValue['categories']).to be_nil.or(be_a Array) 
        end  
      end


    end     
       
  end
    
end
