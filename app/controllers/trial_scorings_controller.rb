class TrialScoringsController < ApplicationController
  def show
    @plant_trial = PlantTrial.find(params[:id])
    params[:model] = 'trial_scoring'

    respond_to do |format|
      format.html do
        @trait_descriptors = TraitDescriptor.
          joins(trait_scores: :plant_scoring_unit).
          where(plant_scoring_units: { plant_trial_id: params[:id].to_i }).
          order('trait_descriptors.id asc').uniq
      end
      format.json do
        cache_key = params.reject{ |k,_| %w(_ controller action format).include? k }
        cache_key[:latest_change] = data_latest_updated_at
        cache_key[:count] = data_count
        logger.info "CACHE KEY: #{cache_key}"
        grid_data = Rails.cache.fetch(cache_key, expires_in: 300.days) do
          logger.info 'MISS MISS MISS'
          prepare_grid_data.to_json
        end
        render json: grid_data
      end
    end
  end

  private

  def prepare_grid_data
    objects = @plant_trial.scoring_table_data(trait_descriptor_ids, current_user.try(:id))
    ApplicationDecorator.decorate(objects).as_grid_data
  end

  def trait_descriptor_ids
    params[:trait_descriptor_ids] || []
  end

  def data_latest_updated_at
    psu_latest_change = @plant_trial.plant_scoring_units.maximum('updated_at')
    ts_latest_change = TraitScore.of_trial(@plant_trial.id).maximum('trait_scores.updated_at')
    [psu_latest_change, ts_latest_change].compact.max
  end

  def data_count
    @plant_trial.plant_scoring_units.count +
    TraitScore.of_trial(@plant_trial.id).count
  end
end
