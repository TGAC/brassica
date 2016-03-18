class PlantTrialsController < ApplicationController
  def show
    @plant_trial = PlantTrial.find(params[:id])
    @trait_scores = @plant_trial
    @trait_descriptors = TraitDescriptor.
      joins(trait_scores: :plant_scoring_unit).
      where(plant_scoring_units: { plant_trial_id: params[:id].to_i }).
      order('trait_descriptors.id asc').uniq
    params[:model] = 'trial_scoring'

    respond_to do |format|
      format.html
      format.json do
        # cache_key = params.reject{ |k,_| %w(_ controller action format).include? k }
        # cache_key[:latest_change] = TraitScore.maximum('updated_at')
        # cache_key[:count] = TraitScore.count
        # logger.info "CACHE KEY: #{cache_key}"
        # grid_data = Rails.cache.fetch(cache_key, expires_in: 300.days) do
        #   logger.info 'MISS MISS MISS'
        #   prepare_grid_data.to_json
        # end
        # render json: grid_data
        render json: prepare_grid_data.to_json
      end
    end
  end

  private

  def prepare_grid_data
    objects = @plant_trial.scoring_table_data(trait_descriptor_ids)
    ApplicationDecorator.decorate(objects).as_grid_data
  end

  def trait_descriptor_ids
    params[:trait_descriptor_ids] || []
  end
end
