module Brassica
  module Api

    def self.models
      (self.readable_models + self.writable_models).uniq
    end

    def self.readable_models
      [PlantPopulation, PlantLine, PlantVariety]
    end

    def self.writable_models
      []
    end
  end
end
