require 'singleton'
class Brapi::V1::StudiesQueries
  include Singleton

  def initialize
    @connection = ActiveRecord::Base.connection.raw_connection    
  end


  # processing result: https://github.com/plantbreeding/API/blob/master/Specification/Studies/SearchStudies.md 
  # All possible fields to return:
  # studyDbId, name, trialDbId, trialName, studyType, seasons, locationDbId, locationName, 
  # programDbId, programName, startDate, endDate, studyType, active, additionalInfo
  # BrAPI v1 doesn't define very well the exact meaning of all these fields
  def studies_search_query(studyType, studyNames, studyLocations, programNames, germplasmDbIds, observationVariableDbIds, 
      active, sortBy, sortOrder, page, page_size, count_mode)
    
    # where conditions
    where_query = " "
    where_atts = []
    where_atts_count = 0
    
    # TODO: We don't support yet these params: studyType, observationVariableDbIds, active
    
    # I think we are not going to differentiate among study data and trial data in brapi
    if studyNames.present?   # plant_trials.plant_trial_name  TODO: FEEDBACK BY ANNEMARIE. MAPPING STUDY = TRIAL
      where_atts_count+= 1
      where_query += get_where_condition("plant_trials.plant_trial_name", studyNames, where_atts_count)
      where_atts << get_att(studyNames)  
    end
    if studyLocations.present?   # countries.country_name
      where_atts_count+= 1
      where_query += get_where_condition("countries.country_name", studyLocations, where_atts_count)
      where_atts << get_att(studyLocations)  
    end
    if programNames.present?   # plant_trials.project_descriptor
      where_atts_count+= 1
      where_query += get_where_condition("plant_trials.project_descriptor", programNames, where_atts_count)
      where_atts << get_att(programNames)  
    end
    if germplasmDbIds.present?   # plant_accessions.plant_accession
      where_atts_count+= 1
      where_query += get_where_condition("plant_accessions.plant_accession", germplasmDbIds, where_atts_count)
      where_atts << get_att(germplasmDbIds)    
    end
    if observationVariableDbIds.present?   # trait_descriptors.id
      where_atts_count+= 1
      where_query += get_where_condition("trait_descriptors.id", observationVariableDbIds, where_atts_count)
      where_atts << get_att(observationVariableDbIds)    
    end
    
    # Until ORCID implementation is done, we only must retrieve published or not owned datasets
    where_atts_count+= 1
    where_query = where_query + (where_atts_count>1?" and ":" where ") 
    where_query += <<-SQL.strip_heredoc
      ((plant_accessions.user_id IS NULL OR plant_accessions.published = TRUE) AND
       (plant_scoring_units.user_id IS NULL OR plant_scoring_units.published = TRUE) AND
       (trait_descriptors.user_id IS NULL OR trait_descriptors.published = TRUE) AND
       (plant_trials.user_id IS NULL OR plant_trials.published = TRUE) )      
    SQL
    
    
    # select clauses
    # studyDbId, name, trialDbId, trialName, studyType, seasons, locationDbId, locationName, 
    # programDbId, programName, startDate, endDate, studyType, active, additionalInfo
    select_query = get_select_distinct_clause(sortBy)
    select_query += <<-SQL.strip_heredoc
      plant_trials.id as "studyDbId", 
      plant_trials.plant_trial_name as "name", 
      null as "trialDbId", 
      null as "trialName",   
      plant_trials.trial_year as "seasons",   
      countries.id as "locationDbId",
      countries.country_name as "locationName",
      plant_trials.project_descriptor as "programName"
    SQL
    
    # TODO: "trialDbId" and "trialName": we don't have our equivalent entity "Investigation" yet.
    # TODO: "seasons": ["2007 Spring", "2008 Fall"] -> seasons themselves not present in our DB
    # TODO: "programDbId": "3" -> WE DON'T HAVE THIS STRUCTURE
    # TODO: "startDate": "2007-06-01" -> NOT PRESENT IN OUR DB
    # TODO: "endDate": "2008-12-31" -> NOT PRESENT IN OUR DB
    # TODO: "studyType": "Trial" -> NOT PRESENT IN OUR DB
    # TODO: "active": true -> TO DEFINE ITS MEANING
    # TODO: "additionalInfo" : { "property1Name" : "property1Value"} -> TO DEFINE ITS MEANING
    
    # joins
    joins_query = 
    "FROM plant_trials
    LEFT JOIN plant_scoring_units ON plant_trials.id = plant_scoring_units.plant_trial_id
    LEFT JOIN plant_accessions ON plant_scoring_units.plant_accession_id = plant_accessions.id
    LEFT JOIN countries ON plant_trials.country_id = countries.id
    LEFT JOIN trait_scores ON plant_scoring_units.id = trait_scores.plant_scoring_unit_id
    LEFT JOIN trait_descriptors ON trait_descriptors.id = trait_scores.trait_descriptor_id
    "
    
    if count_mode
      total_query = "SELECT COUNT(*) FROM ("+select_query + joins_query + where_query +") AS total_entries_count"
      result_object = execute_statement(total_query, where_atts)
    else
      # order
      order_query =  " ORDER BY "+ get_sortby_field(sortBy)      
      order_query += (sortOrder!=nil && sortOrder=="desc"?" desc ":" asc ") 
      
      # pagination
      pagination_query = pagination_query(page, page_size)
      
      total_query = select_query + joins_query + where_query + order_query + pagination_query
      result_object = execute_statement(total_query, where_atts)
    end
    
    result_object
  end



  
  # processing result: https://github.com/plantbreeding/API/blob/master/Specification/Studies/SearchStudies.md 
  # All possible fields to return:
  # studyDbId, studyName, studyType, seasons, trialDbId, trialName, startDate, endDate, active, location 
  # BrAPI v1 doesn't define very well the exact meaning of all these fields
  def studies_get_query(id)
    
    # where conditions
    where_query = " "
    where_atts = []
    where_atts_count = 0
        
    if id.present?   # plant_trials.id
      where_atts_count+= 1
      where_query += get_where_condition("plant_trials.id", id, where_atts_count)
      where_atts << get_att(id)  
    end
    
    
    # Until ORCID implementation is done, we only must retrieve published or not owned datasets
    where_atts_count+= 1
    where_query = where_query + (where_atts_count>1?" and ":" where ") 
    where_query += <<-SQL.strip_heredoc
      ((plant_accessions.user_id IS NULL OR plant_accessions.published = TRUE) AND
       (plant_scoring_units.user_id IS NULL OR plant_scoring_units.published = TRUE) AND
       (plant_trials.user_id IS NULL OR plant_trials.published = TRUE) )      
    SQL
    
    
    # select clauses
    # studyDbId, studyName, studyType, seasons, trialDbId, trialName, startDate, endDate, active 
    # Here the location has a different meaning than studies-search.Location here refers more to a place than the country.
    # location: locationDbId, name, abbreviation, countryCode, countryName, latitude, longitude, altitude, additionalInfo
    select_query = get_select_distinct_clause(" plant_trials.id ")
    select_query += <<-SQL.strip_heredoc
      plant_trials.id as "studyDbId", 
      plant_trials.plant_trial_name as "studyName", 
      plant_trials.trial_year as "seasons",           
      null as "trialDbId", 
      null as "trialName", 
      -- location 
      countries.id as "locationDbId",
      plant_trials.place_name as "name",
      countries.country_code as "countryCode",
      countries.country_name as "countryName",
      plant_trials.latitude as "latitude",
      plant_trials.longitude as "longitude",
      plant_trials.altitude as "altitude",
      plant_trials.terrain as "terrain",
      plant_trials.soil_type as "soil_type",
      -- contacts
      plant_trials.contact_person as "email",
      plant_trials.entered_by_whom as "entered_by_whom_email",
      -- additional info
      plant_trials.plant_trial_description as "studyDescription",
      plant_trials.data_provenance as "dataProvenance",
      plant_trials.data_owned_by as "dataOwnedBy"    
      
    SQL
    
    # TODO: "trialDbId" and "trialName": we don't have our equivalent entity "Investigation" yet.
    # TODO: "studyType": "Trial" -> NOT PRESENT IN OUR DB
    # TODO: "seasons": ["2007 Spring", "2008 Fall"] -> seasons themselves not present in our DB
    # TODO: "startDate": "2007-06-01" -> NOT PRESENT IN OUR DB
    # TODO: "endDate": "2008-12-31" -> NOT PRESENT IN OUR DB
    # TODO: "active": true -> TO DEFINE ITS MEANING
    
    # TODO: "abbreviation": "IB" -> NOT PRESENT IN OUR DB
    # TODO: "additionalInfo" : { "property1Name" : "property1Value"} -> TO DEFINE ITS MEANING
    
    # joins
    joins_query = 
    "FROM plant_trials
    LEFT JOIN plant_scoring_units ON plant_trials.id = plant_scoring_units.plant_trial_id
    LEFT JOIN plant_accessions ON plant_scoring_units.plant_accession_id = plant_accessions.id
    LEFT JOIN countries ON plant_trials.country_id = countries.id
    "
    
    total_query = select_query + joins_query + where_query
    
    result_object = execute_statement(total_query, where_atts)
    
    return result_object
  end


  private

  def get_select_distinct_clause(sortBy)
    distinct_clause = ""
    sort_by_field = get_sortby_field(sortBy) 
    if sort_by_field == " plant_trials.id "
      distinct_clause = "SELECT DISTINCT ON (plant_trials.id)"
    else
      distinct_clause = "SELECT DISTINCT ON (plant_trials.id,"+sort_by_field+")"
    end 
    return distinct_clause
  end

  def get_sortby_field(sortBy)
    order_query = ""
    case sortBy 
    when "studyDbId"   
      order_query += " plant_trials.id "
    when "name"
      order_query += " plant_trials.plant_trial_name "
    when "seasons"
      order_query += " plant_trials.trial_year "
    when "locationDbId"
      order_query += " countries.id "
    when "locationName"
      order_query += " countries.country_name "
    when "programName"
      order_query += " plant_trials.project_descriptor "
    else
      order_query += " plant_trials.id "
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
    # There should be only one 'brapi_statement' prepared and executing running at the same time,
    # at least until the previous one has been deallocated
    Thread.exclusive do
      @connection.prepare('brapi_studies__statement', sql)
      
      if( (atts != nil) && !(atts.empty?) )
        results = @connection.exec_prepared("brapi_studies__statement", atts)
      else
        results = @connection.exec_prepared("brapi_studies__statement")
      end
      @connection.exec("DEALLOCATE brapi_studies__statement")
    end
    return results
  end

  def pagination_query(page, page_size)
    return " LIMIT "+page_size.to_s+" OFFSET "+((page-1)*page_size).to_s  
  end

end
