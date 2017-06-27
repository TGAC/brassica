class Brapi::V1::PhenotypesController < Brapi::BaseController


  attr_accessor :request_params, :user

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: { attribute: exception.param, message: exception.message } }, status: 422
  end


  def search
    # accepted params: germplasmDbIds, observationVariableDbIds, studyDbIds, locationDbIds, seasonDbIds
    # sortBy, sortOrder
    # pageSize, page
    # TODO Not supported yet: programDbIds, observationLevel

    phenotypes_queries = Brapi::V1::PhenotypesQueries.instance
    page = get_page
    page_size = get_page_size 
        
    result_object = phenotypes_queries.phenotypes_search_query(
      params['germplasmDbIds'], params['observationVariableDbIds'], params['studyDbIds'], 
      params['locationDbIds'], params['seasonDbIds'], 
      params['sortBy'], params['sortOrder'], page, page_size, false)
    
    records = result_object.values
   
    if records.nil? || records.size ==0
      render json: { reason: 'Resource not found' }, status: :not_found  # 404
    else
      json_result_array = []
      intermediate_hash = {}
      
      # any programmatic data manipulation can be done here
      result_object.each do |row|
        # To check authentication and ownership when ORCID is supported by BrAPI
        # We currently only retrieve public records. This is already done at query level
        #if (!row[:user_id] || row[:published] )
        
        intermediate_hash_id = row["observationUnitDbId"]
        existing_row = intermediate_hash[intermediate_hash_id]
        
        # We introduce data related to plot numbers, plants, etc
        begin
          observation_levels_hash = JSON.load(row.delete("observation_levels_json"))
          if observation_levels_hash != nil
              row["plotNumber"]= observation_levels_hash["plot"]
              row["plantNumber"]= observation_levels_hash["plant"]
              row["blockNumber"]= observation_levels_hash["block"]
              row["observationLevel"]= observation_levels_hash.keys[observation_levels_hash.keys.length-1]
          end
        rescue JSON::ParserError => e  
          # If there is an unexpected structure in observation_levels_hash, we won't fill that information 
        end
        
        
        observation_hash = {
          observationDbId: row.delete("observations_observationDbId"),
          observationVariableDbId: row.delete("observations_observationVariableDbId"),
          observationVariableName: row.delete("observations_observationVariableName"),
          observationTimeStamp: row.delete("observations_observationTimeStamp"),
          season: row.delete("observations_season"),
          collector: row.delete("observations_collector"),            
          value: row.delete("observations_value")
        }
        
        if existing_row.nil? 
          observations = []
          observations << observation_hash
          row["observations"] = observations
          intermediate_hash[intermediate_hash_id] = row
        else
          existing_row["observations"] << observation_hash 
        end
        

      end
      
      json_result_array = intermediate_hash.values
      
      # pagination data returned
      
      result_count_object = phenotypes_queries.phenotypes_search_query(
      params['germplasmDbIds'], params['observationVariableDbIds'], params['studyDbIds'], params['locationDbIds'],
      params['seasonDbIds'], 
      params['sortBy'], params['sortOrder'], page, page_size, true)
      
      total_count = result_count_object.values.first[0].to_i
      total_pages = (total_count/page_size.to_f).ceil
      
      json_response = { 
        metadata: json_metadata(page_size, page, total_count, total_pages),
        result: {
          data: json_result_array
        }
      }
     
      render json: json_response, except: ["id", "user_id", "created_at", "updated_at", "total_entries_count"]
   
    
    end
  end


  private

  
  def get_page
    return (params[:page].to_i != 0)?params[:page].to_i : 1
  end
  
  def get_page_size
    return (params[:pageSize].to_i != 0)?params[:pageSize].to_i : 1000 
  end
  
  def json_metadata(page_size, current_page, total_count, total_pages)
    json_metadata = {
      status: [],
      datafiles: [],
      pagination: {
        pageSize: page_size, # like 'per_page' in CollectionDecorator
        currentPage: current_page, # like old 'page' in CollectionDecorator
        totalCount: total_count, # like 'total_count'  in CollectionDecorator
        totalPages: total_pages 
      }
    }
  end
  

end
