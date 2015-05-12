module Brassica
  module Api

    def self.models
      self.readable_models | self.writable_models
    end

    def self.readable_models
      [PlantPopulation, PlantLine, PlantVariety]
    end

    def self.writable_models
      [PlantPopulation, PlantLine]
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
end
