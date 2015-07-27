class DataTablesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        double_reference_adjustment
        model_param
      end
      format.json do
        cache_key = params.reject{ |k,_| %w(_ controller action).include? k }
        cache_key[:latest_change] = params[:model].singularize.camelize.constantize.maximum('updated_at')
        cache_key[:count] = params[:model].singularize.camelize.constantize.count
        logger.debug "CACHE KEY: #{cache_key}"
        grid_data = Rails.cache.fetch(cache_key, expires_in: 300.days) do
          logger.debug 'MISS MISS MISS'
          prepare_grid_data.to_json
        end
        render json: grid_data
      end
    end
  end

  def show
    object = model_param.singularize.camelize.constantize.find(params[:id])
    render json: object.annotations_as_json
  end

  private

  def prepare_grid_data
    objects = model_param.singularize.camelize.constantize.table_data(params)
    ApplicationDecorator.decorate(objects).as_grid_data
  end

  def model_param
    if params[:model].present? && !allowed_models.include?(params[:model])
      raise ActionController::RoutingError.new('Not Found')
    end
    params.require(:model)
  end

  def allowed_models
    [
      'linkage_groups',
      'linkage_maps',
      'map_locus_hits',
      'map_positions',
      'marker_assays',
      'plant_accessions',
      'plant_lines',
      'plant_populations',
      'plant_scoring_units',
      'plant_trials',
      'plant_varieties',
      'population_loci',
      'primers',
      'probes',
      'qtl',
      'qtl_jobs',
      'trait_descriptors',
      'trait_scores'
    ]
  end

  def double_reference_adjustment
    ['_a', '_b'].each do |suffix|
      if params[:model].present? && params[:model].end_with?(suffix)
        params[:model] = params[:model][0..-3]
        if params[:query].present? && params[:query]['primers.id'].present?
          params[:query] = { "primer#{suffix}_id" => params[:query]['primers.id'] }
        end
      end
    end
  end
end
