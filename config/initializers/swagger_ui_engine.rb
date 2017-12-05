

SwaggerUiEngine.configure do |config|
  
  config.swagger_url = '/../brapi/v1/apidocs'

  # MULTIPLE VERSIONS ONLY VALID FOR RAILS >=5
  # config.swagger_url = {
  #  v1: '/../brapi/v1/apidocs',
  #  v2: '/../brapi/v1/apidocs'
  #}
  
  config.doc_expansion = 'list'
  
  # NOT AVAILABLE YET: config.json_editor = true 
  # NOT AVAILABLE YET: config.validator_enabled = true
  
end