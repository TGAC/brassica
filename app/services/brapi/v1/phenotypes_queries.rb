require 'singleton'
class Brapi::V1::PhenotypesQueries
  include Singleton

  def initialize
    @connection = ActiveRecord::Base.connection.raw_connection    
  end


  # processing result: https://github.com/plantbreeding/API/blob/master/Specification/Phenotypes/PhenotypeSearch.md
  # All possible fields to return:
  # observationUnitDbId, studyDbId, studyName, studyLocationDbId, studyLocation, observationLevel, observationLevels, 
  # plotNumber, plantNumber, blockNumber, replicate, programName, germplasmDbId, germplasmName, X, Y, treatments, 
  # treatments.factor, treatments.modality, observations, observations.observationDbId, observations.observationVariableDbId, 
  # observations.observationVariableName, observations.season, observations.value, observations.observationTimeStamp,
  # observations.collector
  # BrAPI v1 doesn't define very well the exact meaning of all these fields
  def phenotypes_search_query(query_params, count_mode:)
    germplasm_db_ids= query_params[:germplasm_db_ids] 
    observation_variable_db_ids= query_params[:observation_variable_db_ids]
    study_db_ids= query_params[:study_db_ids] 
    location_db_ids= query_params[:location_db_ids]
    season_db_ids= query_params[:season_db_ids] 
    sort_by= query_params[:sort_by] 
    sort_order= query_params[:sort_order] 
    page= query_params[:page] 
    page_size= query_params[:page_size] 
    
    # where conditions
    where_query = " "
    where_atts = []
    where_atts_count = 0
    
    # TODO: We don't support yet these params: programDbIds, observationLevel
    if germplasm_db_ids.present?   # plant_accessions.plant_accession
      where_atts_count+= 1
      where_query += get_where_condition("plant_accessions.plant_accession", germplasm_db_ids, where_atts_count)
      where_atts << get_att(germplasm_db_ids)    
    end
    if observation_variable_db_ids.present?   # trait_descriptors.id
      where_atts_count+= 1
      where_query += get_where_condition("trait_descriptors.id", observation_variable_db_ids, where_atts_count)
      where_atts << get_att(observation_variable_db_ids)    
    end
    if study_db_ids.present?   # plant_trials.id
      where_atts_count+= 1
      where_query += get_where_condition("plant_trials.id", study_db_ids, where_atts_count)
      where_atts << get_att(study_db_ids)    
    end
    if location_db_ids.present?   # countries.id
      where_atts_count+= 1
      where_query += get_where_condition("countries.id", location_db_ids, where_atts_count)
      where_atts << get_att(location_db_ids)  
    end
    if season_db_ids.present?   # plant_trials.trial_year
      where_atts_count+= 1
      where_query += get_where_condition("plant_trials.trial_year", season_db_ids, where_atts_count)
      where_atts << get_att(season_db_ids)  
    end
    #if observationLevel.present?   
    # observationLevel as param is defined as: level of this observation unit. Its ID is the observationUnitDbId.
    # but the examples show things like 'observationLevel: plot', not an ID at all. So this has to be better defined.
    # Also, in our case observationLevel is a calculated field, so it seems that selection by it cannot be done directly.
    
    # Until ORCID implementation is done, we only must retrieve published or not owned datasets
    where_atts_count+= 1
    where_query = where_query + (where_atts_count>1?" and ":" where ") 
    where_query += <<-SQL.strip_heredoc
      ((plant_accessions.user_id IS NULL OR plant_accessions.published = TRUE) AND
       (plant_scoring_units.user_id IS NULL OR plant_scoring_units.published = TRUE) AND
       (design_factors.user_id IS NULL OR design_factors.published = TRUE) AND
       (trait_scores.user_id IS NULL OR trait_scores.published = TRUE) AND
       (trait_descriptors.user_id IS NULL OR trait_descriptors.published = TRUE) AND
       (plant_trials.user_id IS NULL OR plant_trials.published = TRUE) )      
    SQL
    
    
    # select clauses
    # observationUnitDbId, studyDbId, studyName, studyLocationDbId, studyLocation, observationLevel, observationLevels, 
    # plotNumber, plantNumber, blockNumber, replicate, programName, germplasmDbId, germplasmName, X, Y, treatments, 
    # treatments.factor, treatments.modality, observationUnitXref.source, observationUnitXref.id , 
    # observations, observations.observationDbId, observations.observationVariableDbId, 
    # observations.observationVariableName, observations.season, observations.value, observations.observationTimeStamp,
    # observations.collector
    select_query = " SELECT "  # Not using distinct, as we can have 1 observationUnitDbId with more than 1 observation
    select_query += <<-SQL.strip_heredoc
      plant_scoring_units.id as "observationUnitDbId",
      plant_trials.id as "studyDbId", 
      plant_trials.plant_trial_name as "studyName", 
      countries.id as "studyLocationDbId",
      countries.country_name as "studyLocation",
      regexp_replace(
          regexp_replace(CAST(design_factors.design_factors AS text) , '_', ':', 'g') ,
       '[{}]', '', 'g') as "observationLevels",  
      regexp_replace(
          regexp_replace(CAST(design_factors.design_factors AS text) , '_', ':', 'g') ,
       '([[:alnum:]_]+)', '"\\1"', 'g') as "observation_levels_json",  
      trait_scores.technical_replicate_number as "replicate",
      plant_trials.project_descriptor as "programName",
      plant_accessions.plant_accession as "germplasmDbId", 
      case 
        when plant_lines.common_name != null then plant_lines.common_name
        else plant_lines.plant_variety_name
      end as "germplasmName",
      null as "entryType",
      null as "entryNumber",
      trait_scores.id as "observations_observationDbId",
      trait_descriptors.id as "observations_observationVariableDbId",
      trait_descriptors.descriptor_name as "observations_observationVariableName",
      trait_scores.scoring_date as "observations_season",
      trait_scores.score_value as "observations_value",
      to_char(trait_scores.scoring_date, 'YYYY-MM-DD"T"HH24:MM:SS"Z"') as "observations_observationTimeStamp",
      plant_scoring_units.described_by_whom as "observations_collector"
      
    SQL
    
    # observationLevel, plotNumber, plantNumber, blockNumber, and X, Y have to be extracted 
    #   from observationLevels (observation_levels_json)
    # entryType and entryNumber are not defined at all in BrAPI v1. It seems they always return null.
    # TODO: "treatments.factor": water regimen.
    # TODO: "treatments.modality": water deficit. These two fields maybe were present in CropOntologyDB, 'occasions' table.
    # TODO: "observationUnitXref.source", "observationUnitXref.id"
    
    # joins
    joins_query = 
    "FROM plant_scoring_units
    INNER JOIN plant_trials ON plant_trials.id = plant_scoring_units.plant_trial_id
    LEFT JOIN plant_accessions ON plant_scoring_units.plant_accession_id = plant_accessions.id
    LEFT JOIN countries ON plant_trials.country_id = countries.id
    LEFT JOIN design_factors ON plant_scoring_units.design_factor_id = design_factors.id
    LEFT JOIN plant_lines ON plant_accessions.plant_line_id = plant_lines.id
    LEFT JOIN trait_scores ON plant_scoring_units.id = trait_scores.plant_scoring_unit_id
    LEFT JOIN trait_descriptors ON trait_scores.trait_descriptor_id = trait_descriptors.id
    "

    if count_mode
      total_query = "SELECT COUNT(*) FROM ("+select_query + joins_query + where_query +") AS total_entries_count"
      result_object = execute_statement(total_query, where_atts)
    else
      # order
      order_query =  " ORDER BY "+ get_sortby_field(sort_by)      
      order_query += (sort_order!=nil && sort_order=="desc"?" desc ":" asc ") 
      
      # pagination
      pagination_query = pagination_query(page, page_size)
      
      total_query = select_query + joins_query + where_query + order_query + pagination_query
      result_object = execute_statement(total_query, where_atts)
    end
    result_object
  end


  private


  def get_sortby_field(sort_by)
    order_query = ""
    case sort_by 
    when "germplasmDbIds"   
      order_query += " plant_accessions.plant_accession "
    when "observationVariableDbIds"   
      order_query += " plant_scoring_units.id "
    when "studyDbId"   
      order_query += " plant_trials.id "
    when "locationDbId"
      order_query += " countries.id "
    when "seasons"
      order_query += " plant_trials.trial_year "
    else
      order_query += " plant_scoring_units.id "
    end
    return order_query    
  end

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
      @connection.prepare('brapi_phenotypes_statement', sql)
       
      if( (atts != nil) && !(atts.empty?) )
        results = @connection.exec_prepared("brapi_phenotypes_statement", atts)
      else
        results = @connection.exec_prepared("brapi_phenotypes_statement")
      end
      @connection.exec("DEALLOCATE brapi_phenotypes_statement")
    end
    return results
  end

  def pagination_query(page, page_size)
    return " LIMIT "+page_size.to_s+" OFFSET "+((page-1)*page_size).to_s  
  end

end
