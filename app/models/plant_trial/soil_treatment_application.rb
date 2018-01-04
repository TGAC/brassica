class PlantTrial::SoilTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::SOIL_ROOT_TERM
  end
end
