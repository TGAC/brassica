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
    
    query_params = { 
      germplasm_db_ids: params['germplasmDbIds'], 
      observation_variable_db_ids:params['observationVariableDbIds'],
      study_db_ids: params['studyDbIds'], 
      location_db_ids: params['locationDbIds'],
      season_db_ids: params['seasonDbIds'], 
      sort_by: params['sortBy'], 
      sort_order: params['sortOrder'], 
      page: page, 
      page_size: page_size
    }
    
    result_object = phenotypes_queries.phenotypes_search_query(query_params, count_mode: false )
    records = result_object.values
   
    if result_object.count > 0
      observation_units = []
      observations = Hash.new { |h, k| h[k] = [] }
      #intermediate_hash = {}
      
      # any programmatic data manipulation can be done here
      result_object.each do |observation_row|
        # To check authentication and ownership when ORCID is supported by BrAPI
        # We currently only retrieve public records. This is already done at query level
        #if (!row[:user_id] || row[:published] )
        
        observation_unit_id = observation_row["observationUnitDbId"]
        observation = extract_observation(observation_row)  
        if observations[observation_unit_id].empty?
          observation_row["observations"] = observations[observation_unit_id]
          observation_units << observation_row
        end  
        observations[observation_unit_id] << observation
      end
      
      # pagination data returned
      result_count_object = phenotypes_queries.phenotypes_search_query(query_params, count_mode: true)
      
      total_count = result_count_object.values.first[0].to_i
      total_pages = (total_count/page_size.to_f).ceil
      
      json_response = { 
        metadata: json_metadata(page_size, page, total_count, total_pages),
        result: {
          data: observation_units
        }
      }
      render json: json_response, except: ["id", "user_id", "created_at", "updated_at", "total_entries_count"]
    else
      render json: { reason: 'Resource not found' }, status: :not_found  # 404
    end
  end


  private

  def extract_observation(observation_row)        
    # We introduce data related to plot numbers, plants, etc
    begin
      observation_levels_hash = JSON.load(observation_row.delete("observation_levels_json"))
      if !observation_levels_hash.nil?
          observation_row["plotNumber"]= observation_levels_hash["plot"]
          observation_row["plantNumber"]= observation_levels_hash["plant"]
          observation_row["blockNumber"]= observation_levels_hash["block"]
          observation_row["observationLevel"]= observation_levels_hash.keys[observation_levels_hash.keys.length-1]
      end
    rescue JSON::ParserError => e  
      # If there is an unexpected structure in observation_levels_hash, we won't fill that information 
    end
    
    observation_hash = {
      observationDbId: observation_row.delete("observations_observationDbId"),
      observationVariableDbId: observation_row.delete("observations_observationVariableDbId"),
      observationVariableName: observation_row.delete("observations_observationVariableName"),
      observationTimeStamp: observation_row.delete("observations_observationTimeStamp"),
      season: observation_row.delete("observations_season"),
      collector: observation_row.delete("observations_collector"),            
      value: observation_row.delete("observations_value")
    }
    return observation_hash
  end
  
  def get_page
    return (params[:page].to_i != 0) ? params[:page].to_i : 1
  end
  
  def get_page_size
    return (params[:pageSize].to_i != 0) ? params[:pageSize].to_i : 1000 
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
