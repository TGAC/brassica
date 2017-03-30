class Brapi::V1::GermplasmController < Brapi::BaseController

  attr_accessor :request_params, :user

  before_filter :authenticate_api_key!


  rescue_from 'ActiveRecord::InvalidForeignKey' do |exception|
    message = exception.message.split("\n").try(:second)
    attribute = message ? message[14..-1].split(')')[0] : ''
    render json: { errors: { attribute: attribute, message: message } }, status: 422
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: { attribute: exception.param, message: exception.message } }, status: 422
  end




 def search
    # accepted params: germplasmPUI , germplasmDbId , germplasmName , pageSize , page
    # domainParameters = ['germplasmPUI','germplasmDbId','germplasmName']
    # totalParameters = domainParameters + ['pageSize','page']
    
    if !params['germplasmPUI'].present? && !params['germplasmDbId'].present? && !params['germplasmName'].present?
      render json: { reason: 'Resource not found' }, status: :not_found
    else 
      result_object = germplasm_query(params, false)
      records = result_object.values
      
      
      if records.nil?
        render json: { reason: 'Resource not found' }, status: :not_found
      else
        if records.size == 1 && records[0]!=nil && records[0] != api_key.user_id && records[1] 
          render json: { reason: 'This is a private resource of another user' }, status: :unauthorized
        else
          json_result_array = []
          
          # any programmatic data manipulation can be done here
          result_object.each do |row|
            row = JSON.parse(row["row_to_json"])
            puts row
            if (!row[:user_id] || (row[:user_id]!=nil && row[:user_id] != api_key.user_id && row[:published] ))
              json_result_array << row
            end
          end
          
          # pagination data returned
          page = get_page
          pageSize = get_pageSize 
          
          result_count_object = germplasm_query(params, true)
          totalCount = result_count_object.values.first[0].to_i
          totalPages = (totalCount/pageSize.to_f).ceil
          
          json_response = { 
            'metadata' => json_metadata(pageSize, page, totalCount, totalPages),
            'result' => json_result_array
          }
         
          render json: json_response, :except => ["id", "user_id", "created_at", "updated_at","total_entries_count"]
        end
      end
      
    
    end
  end




  private



  # processing result: https://github.com/plantbreeding/API/blob/master/Specification/Germplasm/GermplasmSearchGET.md 
  # All possible fields to return:
  # germplasmDbId, defaultDisplayName, accessionNumber, germplasmName, germplasmPUI, pedigree, 
  # seedSource, synonyms, commonCropName, instituteCode, instituteName, biologicalStatusOfAccessionCode, 
  # countryOfOriginCode, typeOfGermplasmStorageCode, genus, species, speciesAuthority, subtaxa, subtaxaAuthority, 
  # donors, acquisitionDate

  def germplasm_query(params, count_mode)
    # where conditions
    where_query = " "
    where_atts = []
    where_atts_count = 0
    
    # TO BE DEFINED
    #if params['germplasmPUI'].present? 
    
    if params['germplasmDbId'].present?   # plant_accessions.plant_accession
      where_atts_count+= 1
      where_query = where_query + "where plant_accessions.plant_accession = $"+where_atts_count.to_s
      where_atts<< params['germplasmDbId']
    end
     
    if params['germplasmName'].present?   # plant_lines.plant_variety_name or plant_common_name
      where_atts_count+= 1
      where_query = where_query + where_atts_count==1?" where":" and" + " (plant_lines.plant_variety_name = $"+where_atts_count.to_s+" OR 
       plant_lines.plant_common_name = $"+where_atts_count.to_s+")"
      where_atts<< params['germplasmName']
    end
    
    
    select_query = ""
    
    select_query = "SELECT DISTINCT ON (plant_accessions.id)
    plant_accessions.id,
    plant_accessions.user_id,
    plant_accessions.published,
    plant_accessions.plant_accession as \"germplasmDbId\", 
    case 
      when plant_lines.common_name != null then plant_lines.common_name
      else plant_lines.plant_variety_name
    end as \"defaultDisplayName\",
    plant_accessions.plant_accession as \"accessionNumber\",
    plant_lines.common_name as \"commonCropName\",
    null as \"instituteCode\",
    plant_accessions.originating_organisation as \"instituteName\",
    plant_populations.population_type as \"biologicalStatusOfAccessionCode\",
    case 
      when countries_registered_from_lines.id != null then countries_registered_from_lines.country_code
      else countries_registered_from_accessions.country_code
    end as \"countryOfOriginCode\",
    'Brassica' as \"genus\",
    regexp_replace(taxonomy_terms.name, '( var.).*$', '') as \"species\",  
    taxonomy_terms.name as \"subtaxa\" 
    "
    # TODO : instituteCode mandatory : to be implemented. To review instituteName
    
    
    joins_query = "
    FROM plant_accessions
    INNER JOIN plant_lines ON plant_accessions.plant_line_id = plant_lines.id
    INNER JOIN plant_population_lists ON plant_lines.id = plant_population_lists.plant_line_id
    INNER JOIN plant_populations ON plant_population_lists.plant_population_id = plant_populations.id
    LEFT JOIN plant_varieties AS plant_varieties_from_lines ON plant_lines.plant_variety_id = plant_varieties_from_lines.id 
    LEFT JOIN plant_varieties AS plant_varieties_from_accessions ON plant_accessions.plant_variety_id = plant_varieties_from_accessions.id 
    LEFT JOIN plant_variety_country_registered AS plant_variety_country_registered_from_lines ON plant_varieties_from_lines.id = plant_variety_country_registered_from_lines.plant_variety_id 
    LEFT JOIN plant_variety_country_registered AS plant_variety_country_registered_from_accessions ON plant_varieties_from_accessions.id = plant_variety_country_registered_from_accessions.plant_variety_id 
    LEFT JOIN countries AS countries_registered_from_lines ON plant_variety_country_registered_from_lines.country_id = countries_registered_from_lines.id 
    LEFT JOIN countries AS countries_registered_from_accessions ON plant_variety_country_registered_from_accessions.country_id = countries_registered_from_accessions.id 
    LEFT JOIN taxonomy_terms ON plant_lines.taxonomy_term_id = taxonomy_terms.id
    "
    
    
    # order
    order_query =  " ORDER BY plant_accessions.id desc"
    
    if count_mode
      total_query = "SELECT COUNT(*) FROM ("+select_query + joins_query + where_query + order_query+") AS total_entries_count"

      puts total_query
      result_object = execute_statement(total_query, where_atts)
    else
      # pagination
      page = get_page
      pageSize = get_pageSize
      pagination_query = pagination_query(page, pageSize)
      
      total_query = select_query + joins_query + where_query + order_query + pagination_query
      
      json_wrapping_query = "SELECT row_to_json(row) from ("+total_query+") row"
      
      result_object = execute_statement(json_wrapping_query, where_atts)
    end
    
    records = result_object.values
    result_object
  end


  def pagination_query(page, pageSize)
    return " LIMIT "+pageSize.to_s+" OFFSET "+((page-1)*pageSize).to_s  
  end
  
  
  def get_page
    return (params[:page].to_i != 0)?params[:page].to_i : 1
  end
  
  def get_pageSize
    return (params[:pageSize].to_i != 0)?params[:pageSize].to_i : 1000 
  end
  
  def json_metadata(pageSize, currentPage, totalCount, totalPages)
    json_metadata = {
      status: [],
      files: [],
      pagination: {
        pageSize: pageSize, # old 'per_page'
        currentPage:  currentPage, # old 'page'
        totalCount: totalCount, # old 'total_count'
        totalPages: totalPages 
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


  
  def execute_statement(sql, atts)
      connection = ActiveRecord::Base.connection.raw_connection

      connection.prepare('brapi_statement', sql)
      
      if( (atts != nil) && !(atts.empty?) )
        results = connection.exec_prepared("brapi_statement", atts)
      else
        results = connection.exec_prepared("brapi_statement")
      end
      connection.exec("DEALLOCATE brapi_statement")

      if results.present?
          return results
      else
          return nil
      end
  end

end
