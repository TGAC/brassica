class SearchesController < ApplicationController
  def counts
    @term = params[:search]
    @counts = Search.new(@term).counts

    render layout: !request.xhr?
  end
end
