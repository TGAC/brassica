class Brapi::V1::VariablesController < Brapi::BaseController

  attr_accessor :request_params, :user


  def list
    # pageSize, page
    # TODO Not supported yet: traitClass

    variables_queries = Brapi::V1::VariablesQueries.instance
    page = get_page
    page_size = get_page_size 
    
    query_params = { 
      page: page, 
      page_size: page_size
    }
    
    result_object = variables_queries.variables_list_query(query_params, count_mode: false )
    if result_object.nil?
      render json: { reason: 'Internal error', message: 'There was some error managing phenotypes/search query' }, status: :internal_server_error
    else
      records = result_object.values
     
      if result_object.count > 0
        # any programmatic data manipulation can be done here
        observation_variables = []
        result_object.each do |row|
          # To check authentication and ownership when ORCID is supported by BrAPI
          # We currently only retrieve public records. This is already done at query level
          #if (!row[:user_id] || row[:published] )                   
          row["trait"] = extract_trait(row)
          row["method"] = extract_method(row)
          row["scale"] = extract_scale(row)         
          observation_variables << row
        end
        
        # pagination data returned
        result_count_object = variables_queries.variables_list_query(query_params, count_mode: true)
        
        total_count = result_count_object.values.first[0].to_i
        total_pages = (total_count/page_size.to_f).ceil
        
        json_response = { 
          metadata: json_metadata(page_size, page, total_count, total_pages),
          result: {
            data: observation_variables
          }
        }
        render json: json_response
      else
        render json: { reason: 'Resource not found' }, status: :not_found  # 404
      end
    end
  end


  private

  def extract_trait(row)            
    trait_hash = {
      traitDbId: row.delete("traits_traitDbId"),
      name: row.delete("traits_name"),
      class: row.delete("traits_class"),
      entity: row.delete("traits_entity"),
    }
  end
  
  def extract_method(row)            
    method_hash = {
      class: row.delete("methods_class"),
      description: row.delete("methods_description")
    }
  end
  
  def extract_scale(row)            
    scale_hash = {
      name: row.delete("scales_name")
    }
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
