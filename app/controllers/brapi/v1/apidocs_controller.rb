class Brapi::V1::ApidocsController < ApplicationController
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '0.4'
      key :title, 'BIP BrAPI v1 endpoint '
      key :description, 'Brassica Information Portal: BrAPI implementation'
      contact do
        key :name, 'BIP support'
        key :url, 'https://bip.earlham.ac.uk/about'
        key :email, 'bip@earlham.ac.uk'
      end
      license do
        key :name, 'GPLv3'
        key :url, 'https://www.gnu.org/licenses/gpl-3.0.en.html'
      end
    end
    tag do
      key :name, 'Germplasm'
      key :description, 'Germplasm-related calls'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://github.com/plantbreeding/API/tree/master/Specification/Germplasm'
      end
    end
    tag do
      key :name, 'Phenotypes'
      key :description, 'Phenotyping-related calls'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://github.com/plantbreeding/API/tree/master/Specification/Phenotypes'
      end
    end
    tag do
      key :name, 'Studies'
      key :description, 'Study-related calls'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://github.com/plantbreeding/API/tree/master/Specification/Studies'
      end
    end
    # IGNORED BY THE ENGINE key :host, 'http://localhost:3000'
    # IGNORED BY THE ENGINE key :basePath, '/swagger-apidocs'
    key :consumes, ['application/json']
    key :produces, ['application/json']
    
    parameter :germplasmDbId do
      key :name, :germplasmDbId
      key :in, :query
      key :description, 'Germplasm Internal Identifier'
      key :required, false
      key :type, :string
    end
    parameter :germplasmName do
      key :name, :germplasmName
      key :in, :query
      key :description, 'Name of the germplasm'
      key :required, false
      key :type, :string
    end
    parameter :germplasmPUI do
      key :name, :germplasmPUI
      key :in, :query
      key :description, 'Germplasm Permanent Identifier'
      key :required, false
      key :type, :string
    end
    parameter :studyType do
      key :name, :studyType
      key :in, :query
    # TODO: To be clarified   key :description, ''
      key :required, false
      key :type, :string
    end
    
    parameter :pageSize do
      key :name, :pageSize
      key :in, :query
      key :description, 'The size of the pages to be returned. Default is 1000.'
      key :required, false
      key :type, :integer
      key :format, :int64
    end
    parameter :page do
      key :name, :page
      key :in, :query
      key :description, 'Which result page is requested. First page is 1.'
      key :required, false
      key :type, :integer
      key :format, :int64
    end
    parameter :sortBy do
      key :name, :sortBy
      key :in, :query
      key :description, 'Field to be used for sorting results'
      key :required, false
      key :type, :integer
      key :format, :int64
    end
    parameter :sortOrder do
      key :name, :sortOrder
      key :in, :query
      key :description, 'Sort order (desc or asc). desc by default.'
      key :required, false
      key :type, :integer
      key :format, :int64
    end
    
    
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    Brapi::V1::GermplasmController,
    Brapi::V1::PhenotypesController,
    Brapi::V1::StudiesController,
    Swagger::Brapi::V1::ApidocsModel,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end

end
