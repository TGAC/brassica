class Api
  def self.models
    self.readable_models | self.writable_models
  end

  def self.readable_models
    [
      Country,
      LinkageGroup,
      LinkageMap,
      MapLocusHit,
      MapPosition,
      MarkerAssay,
      PlantAccession,
      PlantLine,
      PlantPopulation,
      PlantPopulationList,
      PlantScoringUnit,
      PlantTrial,
      PlantVariety,
      PopulationLocus,
      PopulationType,
      Primer,
      Probe,
      Qtl,
      QtlJob,
      TaxonomyTerm,
      TraitDescriptor,
      TraitScore
    ]
  end

  def self.writable_models
    [
      LinkageGroup,
      LinkageMap,
      MapLocusHit,
      MapPosition,
      MarkerAssay,

      PlantAccession,
      PlantLine,
      PlantPopulation,
      PlantPopulationList,
      PlantScoringUnit,
      PlantTrial,
      PlantVariety,
      TraitDescriptor,
      TraitScore,

      PopulationLocus,
      Primer,
      Probe,
      Qtl,
      QtlJob
    ]
  end

  def self.readonly_models
    readable_models - writable_models
  end

  def self.readable_model?(model)
    @readable ||= readable_models.map { |m| m.name.underscore }
    @readable.include?(model.to_s.underscore.singularize)
  end

  def self.writable_model?(model)
    @writable ||= writable_models.map { |m| m.name.underscore }
    @writable.include?(model.to_s.underscore.singularize)
  end
end
