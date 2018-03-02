class PlantTrial::RadiationTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::RADIATION_ROOT_TERM
  end
end
