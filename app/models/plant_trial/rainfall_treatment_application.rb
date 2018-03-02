class PlantTrial::RainfallTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::RAINFALL_ROOT_TERM
  end
end
