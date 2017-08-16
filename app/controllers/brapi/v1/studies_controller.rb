class Brapi::V1::StudiesController < Brapi::BaseController
  include Swagger::Blocks
  # Swagger API doc
  swagger_path '/brapi/v1/studies-search' do
    operation :post do
      key :summary, 'Search of studies by different params'
      key :description, 'Returns zero, one or multiple studies'
      key :operationId, 'studies-search'
      key :tags, [
        'Studies'
      ]
      parameter do
        key :name, :studies_search_params
        key :in, :body
        key :description, 'Search parameters.'
        key :required, false
        schema do
          key :'$ref', :StudiesSearchInput
        end
      end
      
      response :not_found do
        key :description, 'There were not any study with the required params' 
      end
      response :unprocessable_entity do
        key :description, 'There was an error managing the internal query' 
      end
      response :default do
        key :description, 'list of studies'
      end
    end
  end
  
  swagger_path '/brapi/v1/studies/{id}' do
    operation :get do
      key :summary, 'Shows information related to one study by its id'
      key :description, 'Returns full information of one study'
      key :operationId, 'studies-show'
      key :tags, [
        'Studies'
      ]
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'Identifier of the study. Usually a number, could be alphanumeric'
        key :required, true
        key :type, :string
      end
      response :not_found do
        key :description, 'There were not any study with the required params' 
      end
      response :unprocessable_entity do
        key :description, 'There was an error managing the internal query' 
      end
      response :default do
        key :description, 'Full study information'
      end
    end
  end
  
  swagger_path '/brapi/v1/studies/{studyDbId}/germplasm' do
    operation :get do
      key :summary, 'Shows germplasm related to one study'
      key :description, 'Returns germplasm related of one study'
      key :operationId, 'studies-germplasm'
      key :tags, [
        'Studies'
      ]
      parameter do
        key :name, :studyDbId
        key :in, :path
        key :description, 'Identifier of the study. Usually a number, could be alphanumeric'
        key :required, true
        key :type, :string
      end
      parameter :page
      parameter :pageSize
      
      response :not_found do
        key :description, 'There were not any germplasm related to the study with the required params' 
      end
      response :unprocessable_entity do
        key :description, 'There was an error managing the internal query' 
      end
      response :default do
        key :description, 'Full germplasm information'
      end
    end
  end
  
  
  attr_accessor :request_params, :user

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: { attribute: exception.param, message: exception.message } }, status: 422
  end


  def search
    # accepted params: studyType, studyNames, studyLocations, programNames, germplasmDbIds
    # observationVariableDbIds, active, sortBy, sortOrder
    # pageSize, page

    # At least one implemented search parameter should be provided
    if !params['studyType'].present? && !params['studyNames'].present? && !params['studyLocations'].present? && 
        !params['programNames'].present? && !params['germplasmDbIds'].present? && 
        !params['observationVariableDbIds'].present? && !params['active'].present? && 
        !params['sortBy'].present? && !params['sortOrder'].present?
      raise ActionController::ParameterMissing.new('Not Found')
    else 
      studies_queries = Brapi::V1::StudiesQueries.instance
      page = get_page
      page_size = get_page_size 
          
      query_params = { 
        study_type: params['studyType'], 
        study_names: params['studyNames'],
        study_locations: params['studyLocations'],
        program_names: params['programNames'],
        germplasm_db_ids: params['germplasmDbIds'],
        observation_variable_db_ids: params['observationVariableDbIds'],
        active: params['active'],
        sort_by: params['sortBy'],
        sort_order: params['sortOrder'],
        page: page, 
        page_size: page_size
      }   
          
      result_object = studies_queries.studies_search_query(query_params, count_mode: false)
      
      if result_object.nil?
        render json: { reason: 'Internal error', message: 'There was some error managing studies/search query' }, status: :internal_server_error
      else
        records = result_object.values
       
        if records.nil? || records.size ==0
          render json: { reason: 'Resource not found' }, status: :not_found  # 404
        else
          json_result_array = []
          
          # any programmatic data manipulation can be done here
          result_object.each do |row|
            row[:seasons] = [row["seasons"]]
            
            # To check authentication and ownership when ORCID is supported by BrAPI
            # We currently only retrieve public records. This is already done at query level
            #if (!row[:user_id] || row[:published] )
            json_result_array << row
            #end
          end
          
          # pagination data returned
          
          result_count_object = studies_queries.studies_search_query(query_params, count_mode: true)
          
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
    end
  end


  def show
    # accepted params: id

    if !params['id'].present? 
      raise ActionController::ParameterMissing.new('Not Found')
    else 
      studies_queries = Brapi::V1::StudiesQueries.instance
          
      result_object = studies_queries.studies_get_query(params['id'])
      if result_object.nil?
        render json: { reason: 'Internal error', message: 'There was some error managing studies/show query' }, status: :internal_server_error
      else
        records = result_object.values
       
        if records.nil? || records.size == 0
          render json: { reason: 'Resource not found' }, status: :not_found  # 404
        else
          json_result_array = []
          
          # any programmatic data manipulation can be done here
          result_object.each do |row|          
            row[:seasons] = [row["seasons"]]
            
            location_hash = row.extract!("locationDbId", "name", "countryCode", "countryName", "latitude", 
              "longitude", "altitude")
            location_hash[:additional_info] = row.extract!("terrain", "soil_type")
            row[:location] = [location_hash]
            
            contact1_hash = row.extract!("email")
            contact2_hash = {email: row["entered_by_whom_email"], type: "data_introducer"}
            row.delete("entered_by_whom_email")
            row[:contacts] = [contact1_hash, contact2_hash]
            
            additional_info_hash = row.extract!("studyDescription", "dataProvenance", "dataOwnedBy")
            row[:additionalInfo] = additional_info_hash
            
            # To check authentication and ownership when ORCID is supported by BrAPI
            # We currently only retrieve public records. This is already done at query level
            #if (!row[:user_id] || row[:published] )
            json_result_array << row
            #end
          end
          
          json_response = { 
            metadata: json_metadata(0, 0, records.size, 0),
            result: json_result_array
          }
         
          render json: json_response, except: ["id", "user_id", "created_at", "updated_at", "total_entries_count"]
        end
      end
    
    end
    
  end



  def germplasm
    # accepted params: studyDbId
    # pageSize, page

    # studyDbId should be provided
    if !params['studyDbId'].present? 
      raise ActionController::ParameterMissing.new('Not Found')
    else  
      studies_queries = Brapi::V1::StudiesQueries.instance
      page = get_page
      page_size = get_page_size 
        
      query_params = { 
        study_db_id: params['studyDbId'], 
        sort_by: params['sortBy'], 
        sort_order: params['sortOrder'], 
        page: page, 
        page_size: page_size
      }  
          
      result_object = studies_queries.germplasm_query(query_params, count_mode: false )  
      
      if result_object.nil?
        render json: { reason: 'Internal error', message: 'There was some error managing studies/germplasm query' }, status: :internal_server_error
      else
        records = result_object.values
        if records.nil? || records.size == 0
          render json: { reason: 'Resource not found' }, status: :not_found  # 404
        else
          json_result_array = []
          entry_number = 1 + ((page-1) * page_size)
          # any programmatic data manipulation can be done here
          result_object.each do |row|
            row[:entryNumber] = entry_number.to_s
            entry_number += 1
            
            # To check authentication and ownership when ORCID is supported by BrAPI
            # We currently only retrieve public records. This is already done at query level
            #if (!row[:user_id] || row[:published] )
            json_result_array << row
            #end
          end
          
          # pagination data returned
          
          result_count_object = studies_queries.germplasm_query(query_params, count_mode: true )
          
          total_count = result_count_object.values.first[0].to_i
          total_pages = (total_count/page_size.to_f).ceil
          
          json_response = { 
            metadata: json_metadata(page_size, page, total_count, total_pages),
            result: {
              studyDbId: params['studyDbId'],
              data: json_result_array
            }
          }
         
          render json: json_response, except: ["id", "user_id", "created_at", "updated_at", "total_entries_count"]
        end
        
      end
    
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
