# Single Concern for all searcheable/filterable models.
# Provides the 'filter' scope, to be used like this:
#  - params[:query] - exact filtering, also by associated model fields e.g.
#    - query: { common_name: 'cn', plant_line_name: ['pln'] }
#    - query: { 'plant_populations.plant_population_id' => 'pid' }
#      - this one performs the required join
#  - params[:search] - ILIKE filtering
#    - search: { common_name: 'cn' }
#  - possible multiple search, and multiple query criteria
#  - IMPORTANT: requires declared self.permitted_params for strong
#               parameters filtering
#  - possible joint search and query criteria
module Filterable extend ActiveSupport::Concern

  included do
    include Joinable

    def self.filter(params, query = all)
      params = filter_params(params)
      if params[:query].present? || params[:search].present?
        query = query.where(params[:query]) if params[:query].present?
        params[:search].each do |k,v|
          query = query.where("#{k} ILIKE ?", "%#{v}%")
        end if params[:search].present?
      elsif params[:fetch].present?
        ids = Search.new(params[:fetch]).send(table_name).records.ids
        query = query.where(id: ids)
      else
        query = none
      end
      query = join_columns(params[:query].keys, query) if params[:query].present?
      query
    end

    private

    def self.filter_params(unsafe_params)
      unsafe_params = ActionController::Parameters.new(unsafe_params)
      unsafe_params.permit(permitted_params)
    end

    # By default, do not permit any parameter
    def self.permitted_params; end

    # Helper method for models permitting more parameters
    # Filters out parameter names unfit for direct filtering
    def self.params_for_filter(params)
      params.reject do |param|
        param.include?('.') || param.match(/as/i)
      end
    end
  end
end
