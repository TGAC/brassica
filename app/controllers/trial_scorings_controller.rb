class TrialScoringsController < ApplicationController
  def show
    @plant_trial = PlantTrial.find(params[:id])
    params[:model] = 'trial_scoring'

    respond_to do |format|
      format.html
      format.json do
        logger.info "CACHE KEY: #{cache_key}"
        grid_data = Rails.cache.fetch(cache_key, expires_in: 300.days) do
          logger.info 'MISS MISS MISS'
          prepare_grid_data.to_json
        end
        render json: grid_data
      end
      format.zip do
        send_data Submission::PlantTrialZipExporter.new.call(@plant_trial, cache_key).read,
                  filename: "plant_trial_#{@plant_trial.plant_trial_name.parameterize(separator: '_')}.zip",
                  type: 'application/zip'
      end
    end
  end

  private

  def cache_key
    params.reject{ |k,_| %w(_ controller action).include? k }.merge({
      latest_change: data_latest_updated_at,
      count: data_count
    })
  end

  def prepare_grid_data
    objects = @plant_trial.scoring_table_data(user_id: current_user.try(:id))
    ApplicationDecorator.decorate(objects).as_grid_data
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
