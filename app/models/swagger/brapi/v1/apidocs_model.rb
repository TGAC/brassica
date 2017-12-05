class Swagger::Brapi::V1::ApidocsModel
 include Swagger::Blocks


  swagger_schema :PhenotypesSearchInput  do
    property :germplasmDbIds do
      key :description, 'The name or synonym of external genebank accession identifiers'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :observationVariableDbIds do
      key :description, 'The IDs of traits, could be ontology ID, database ID or PUI'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :studyDbIds do
      key :description, 'The database ID / PK of the studies search parameter'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :locationDbIds do
      key :description, 'locations these traits were collected'
      key :type, :array
      items do
        key :type, :string
      end
    end
    # TODO property :programDbIds do
    #  key :description, 'list of programs that have characterized this trait'
    #  key :type, :array
    #  items do
    #    key :type, :string
    #  end
    #end
    property :seasonDbIds do
      key :description, 'The year or Phenotyping campaign of a multiannual study'
      key :type, :array
      items do
        key :type, :string
      end
    end
    # TODO property :observationLevel do
    #  key :description, 'The type of the observationUnit. Returns only the observaton unit of the specified type; the parent levels ID can be accessed through observationUnitStructure.'
    #  key :type, :string
    # end
    property :observationTimeStampRange do
      key :description, 'Range of dates in Iso Standard 8601. observationValue data type inferred from the ontology'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :pageSize do
      key :description, 'The size of the pages to be returned. Default is `1000`.'
      key :type, :integer
      key :format, :int64
    end
    property :page do
      key :description, 'Which result page is requested. First page is 1.'
      key :type, :integer
      key :format, :int64
    end
    
  end
  
  
  

  swagger_schema :StudiesSearchInput  do
    # TODO property :studyType do
      # TODO: To be defined  key :description, ''
    #  key :type, :string
    #end
    property :studyNames do
      key :description, 'The name of the studies search parameter'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :studyLocations do
      key :description, 'locations these studies were done'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :programNames do
      key :description, 'list of programs that have managed these studies'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :germplasmDbIds do
      key :description, 'The name or synonym of external genebank accession identifiers'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :observationVariableDbIds do
      key :description, 'The IDs of traits, could be ontology ID, database ID or PUI'
      key :type, :array
      items do
        key :type, :string
      end
    end
   # TODO property :active do
      # TODO: To be defined  key :description, ''
   #   key :type, :string
   # end
    
    property :sortBy do
      key :description, 'Field to be used for sorting results'
      key :type, :string
    end
    property :sortOrder do
      key :description, 'Sort order (desc or asc). desc by default.'
      key :type, :string
    end
    property :pageSize do
      key :description, 'The size of the pages to be returned. Default is `1000`.'
      key :type, :integer
      key :format, :int64
    end
    property :page do
      key :description, 'Which result page is requested. First page is 1.'
      key :type, :integer
      key :format, :int64
    end
    
  end
  
end