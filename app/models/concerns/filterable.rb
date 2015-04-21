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
    def self.filter(params)
      params = filter_params(params)
      query = if params[:query].present? || params[:search].present?
        query = all
        query = query.where(params[:query]) if params[:query].present?
        params[:search].each do |k,v|
          query = query.where("#{k} ILIKE ?", "%#{v}%")
        end if params[:search].present?
        query
      else
        none
      end

      params[:query].each do |k,_|
        if k.to_s.include? '.'
          relation = k.to_s.split('.')[0].pluralize
          next unless relation and relation != self.table_name
          relation = relation.singularize unless reflections.keys.include?(relation)
          query = query.joins(relation.to_sym)
        end
      end if params[:query].present?
      query
    end

    private

    def self.filter_params(unsafe_params)
      unsafe_params = ActionController::Parameters.new(unsafe_params)
      unsafe_params.permit(permitted_params)
    end

    # By default, do not permit any parameter
    def self.permitted_params; end
  end
end
