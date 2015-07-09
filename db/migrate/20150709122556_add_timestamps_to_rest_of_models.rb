class AddTimestampsToRestOfModels < ActiveRecord::Migration
  def up
    safe_day = Time.now - 8.days

    models.each do |model_klass|
      add_timestamps model_klass.table_name.to_sym
      model_klass.update_all(
        created_at: safe_day,
        updated_at: safe_day
      )
    end
  end

  def down
    models.each do |model_klass|
      remove_timestamps model_klass.table_name.to_sym
    end
  end

  def models
    [
      Country,
      LinkageGroup,
      LinkageMap,
      MapLocusHit,
      MapPosition,
      MarkerAssay,
      PopulationLocus,
      PopulationType,
      Primer,
      Probe,
      Qtl,
      QtlJob
    ]
  end
end
