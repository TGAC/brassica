class PlantTrial::HerbicideTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::HERBICIDE_ROOT_TERM
  end
end
