require 'singleton'
class Brapi::V1::VariablesQueries
  include Singleton

  def initialize
    @connection = ActiveRecord::Base.connection.raw_connection   
    @connection.exec("set statement_timeout to 10000;")      
  end


  # processing result: https://github.com/plantbreeding/API/blob/master/Specification/ObservationVariables/VariableList.md
  # All possible fields to return:
  # observationVariableDbId, name, ontologyDbId, ontologyName, synonyms, contextOfUse, growthStage, status,
  # xref, institution, scientist, submissionTimestamp, language, crop, 
  # trait_traitDbId, trait_name, trait_class, trait_description, trait_synonyms, trait_mainAbbreviation, 
  # trait_alternativeAbbreviations, trait_entity, trait_attribute, trait_status, trait_xref,
  # method_methodDbId, method_name, method_class, method_description, method_formula, method_reference
  # scale_scaleDbId, scale_name, scale_datatype, scale_decimalPlaces, scale_xref, scale_validValues {min, max, categories}
  # defaultValue
  # BrAPI v1 doesn't define very well the exact meaning of all these fields
  def variables_list_query(query_params, count_mode:)
    page= query_params[:page] 
    page_size= query_params[:page_size] 
    
    # where conditions
    where_query = " "
    where_atts = []
    where_atts_count = 0
    
    # TODO: We don't support yet these params: traitClass
    
    # Until ORCID implementation is done, we only must retrieve published or not owned datasets
    where_atts_count+= 1
    where_query = where_query + (where_atts_count>1?" and ":" where ") 
    where_query += <<-SQL.strip_heredoc
      ( (trait_descriptors.user_id IS NULL OR trait_descriptors.published = TRUE)  )      
    SQL
    
    
    # select clauses
    # observationVariableDbId, name, ontologyDbId, ontologyName, synonyms, contextOfUse, growthStage, status,
    # xref, institution, scientist, submissionTimestamp, language, crop, 
    # trait: traitDbId, name, class, description, synonyms, mainAbbreviation, alternativeAbbreviations, entity,
    #   attribute, status, xref
    # method: methodDbId, name, class, description, formula, reference
    # scale: scaleDbId, name, datatype, decimalPlaces, xref, validValues (min, max, categories)
    # defaultValue (always null)
    select_query = " SELECT DISTINCT ON (trait_descriptors.id) "
    select_query += <<-SQL.strip_heredoc
    
      trait_descriptors.id as "observationVariableDbId",
      trait_descriptors.descriptor_name as "name",
      traits.label as "ontologyDbId",
      traits.data_provenance as "ontologyName",
      trait_descriptors.stage_scored as "growthStage",
      trait_descriptors.data_owned_by as "institution",
      case 
        when trait_descriptors.entered_by_whom != null then trait_descriptors.entered_by_whom
        else trait_descriptors.contact_person
      end as "scientist",
      null as "defaultValue", 
      -- plant_lines.common_name as "crop",
      -- Traits
      trait_descriptors.trait_id as "traits_traitDbId",  
      trait_descriptors.descriptor_name as "traits_name",
      trait_descriptors.category as "traits_class",     
      plant_parts.plant_part as "traits_entity",  --  trait_descriptors.plant_part_id
      -- Methods
      trait_descriptors.score_type as "methods_class",
      CONCAT_WS('. ',trait_descriptors.scoring_method,trait_descriptors.when_to_score, 
        trait_descriptors.where_to_score, trait_descriptors.instrumentation_required, 
        trait_descriptors.calibrated_against, trait_descriptors.likely_ambiguities, 
        trait_descriptors.materials, trait_descriptors.controls) as "methods_description",
      -- Scale
      trait_descriptors.units_of_measurements as "scales_name"     
    SQL

    # TODO: "Synonyms"
    # TODO: "contextOfUse"
    # TODO: "status"
    # TODO: "xref"
    # TODO: "language"
    # Traits
    # TODO: "description"
    # TODO: "synonyms"
    # TODO: "mainAbbreviation"
    # TODO: "alternativeAbbreviations"
    # TODO: "attribute"
    # TODO: "status"
    # TODO: "xref"
    # Note: traits_traitDbId uses trait_descriptors.trait_id instead trait_descriptors.id 
    # (as it should be following the official mapping spreadsheet), based on the examples given.
    # Methods
    # TODO: "methodDbId"
    # TODO: "name"
    # TODO: "formula"
    # TODO: "reference"
    # Scale
    # TODO: "scaleDbId"
    # TODO: "datatype"
    # TODO: "decimalPlaces"
    # TODO: "xref"
    # TODO: "validValues (min, max, categories)"
    
    
    # joins
    joins_query = "
    FROM trait_descriptors
    LEFT JOIN traits ON trait_descriptors.trait_id = traits.id
    LEFT JOIN plant_parts ON trait_descriptors.plant_part_id = plant_parts.id
    -- LEFT JOIN processed_trait_datasets ON processed_trait_datasets.trait_descriptor_id = trait_descriptors.id
    "
    
    if count_mode
      total_query = "SELECT COUNT(*) FROM ("+select_query + joins_query + where_query +") AS total_entries_count"
      result_object = execute_statement(total_query, where_atts)
    else
      # order
      order_query =  " ORDER BY trait_descriptors.id asc"
      
      # pagination
      pagination_query = pagination_query(page, page_size)
      
      total_query = select_query + joins_query + where_query + order_query + pagination_query
      puts "total query"
      puts total_query
      result_object = execute_statement(total_query, where_atts)
    end
    result_object
  end


  private


  def get_where_condition(field, value, condition_number )
    where_clause = (condition_number > 1 ? " and " : " where ") 
    if value.kind_of?(Array)
      where_clause += " "+field+" = ANY($"+condition_number.to_s+")"
    else
      where_clause += " "+field+" = $"+condition_number.to_s  
    end  
    return where_clause
  end
  
  def get_att(att)
    if att.kind_of?(Array)
      return get_array(att)
    else
      return att
    end   
  end
  
  def get_array(array)
    if array.kind_of?(Array)
      array_string = "{"
      array.each_with_index do |el, index|
        array_string += el
        if (index<(array.size-1))
          array_string += ","
        end
      end
      array_string += "}"
      return array_string 
    else
      array
    end
  end

  def execute_statement(sql, atts)
    results = []
    # There should be only one 'brapi_phenotypes_statement' prepared and executing running at the same time,
    # at least until the previous one has been deallocated
    Thread.exclusive do
      @connection.prepare('brapi_variables_statement', sql)
      begin 
        if( (atts != nil) && !(atts.empty?) )
          results = @connection.exec_prepared("brapi_variables_statement", atts)
        else
          results = @connection.exec_prepared("brapi_variables_statement")
        end
      rescue PG::Error => e
        @connection.exec("ROLLBACK") 
        raise Brapi::QueryError.new([sql,atts])        
      ensure
        @connection.exec("DEALLOCATE brapi_variables_statement")
      end  
    end
    return results
  end

  def pagination_query(page, page_size)
    return " LIMIT "+page_size.to_s+" OFFSET "+((page-1)*page_size).to_s  
  end

end
