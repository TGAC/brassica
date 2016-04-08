require 'typhoeus/adapters/faraday'  # Due to: https://github.com/elastic/elasticsearch-rails/issues/481
require 'elasticsearch'

Elasticsearch::Model.client = Elasticsearch::Client.new(Rails.application.config_for(:elasticsearch))
