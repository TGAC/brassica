class Brapi::V1::GermplasmController < Brapi::BaseController

  attr_accessor :request_params, :user

  # Authentication via ORCID is currently unsupported by BrAPI.
  # before_filter :authenticate_api_key!


  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: { attribute: exception.param, message: exception.message } }, status: 422
  end




  def search
    # accepted params: germplasmPUI , germplasmDbId , germplasmName , pageSize , page
    
    if !params['germplasmPUI'].present? && !params['germplasmDbId'].present? && !params['germplasmName'].present?
      raise ActionController::ParameterMissing.new('Not Found')
    else 
      germplasm_queries = Brapi::V1::GermplasmQueries.instance
      page = get_page
      page_size = get_page_size 
          
      result_object = germplasm_queries.germplasm_search_query(
        params['germplasmPUI'],params['germplasmDbId'], params['germplasmName'], page, page_size, false)
      
      records = result_object.values
     
      if records.nil? || records.size ==0
        render json: { reason: 'Resource not found' }, status: :not_found  # 404
      else
        
        json_result_array = []
        
        # any programmatic data manipulation can be done here
        result_object.each do |row|
          row = JSON.parse(row["row_to_json"])
          
          # To check authentication and ownership when ORCID is supported by BrAPI
          # We currently only retrieve public records. This is already done at query level
          #if (!row[:user_id] || row[:published] )
          json_result_array << row
          #end
        end
        
        # pagination data returned
        
        result_count_object = germplasm_queries.germplasm_search_query(
          params['germplasmPUI'],params['germplasmDbId'], params['germplasmName'], page, page_size, true)
        total_count = result_count_object.values.first[0].to_i
        total_pages = (total_count/page_size.to_f).ceil
        
        json_response = { 
          'metadata' => json_metadata(page_size, page, total_count, total_pages),
          'result' => json_result_array
        }
       
        render json: json_response, :except => ["id", "user_id", "created_at", "updated_at", "total_entries_count"]
      
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
      files: [],
      pagination: {
        pageSize: page_size, # old 'per_page'
        currentPage:  current_page, # old 'page'
        totalCount: total_count, # old 'total_count'
        totalPages: total_pages 
      }
    }
  end
  


  def authenticate_api_key!
    unless api_key_token.present?
      render json: '{"reason": "BIP API requires API key authentication"}', status: 401
      return
    end
    unless api_key.present?
      if api_key_token == I18n.t('api.general.demo_key')
        render json: '{"reason": "Please use your own, personal API key"}', status: 401
      else
        render json: '{"reason": "Invalid API key"}', status: 401
      end
    end
  end

  def api_key_token
    return @api_key_token if defined?(@api_key_token)
    token = params[:api_key] || request.headers["X-BIP-Api-Key"]
    @api_key_token = ApiKey.normalize_token(token)
  end

  def api_key
    return @api_key if defined?(@api_key)
    @api_key = api_key_token && ApiKey.find_by(token: api_key_token)
  end


end
