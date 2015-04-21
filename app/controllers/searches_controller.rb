class SearchesController < ApplicationController

  def new
    results = Search.new(params[:search]).counts
    results = SearchResultsDecorator.new(counts: results).as_autocomplete_data
    render json: results
  end

end
