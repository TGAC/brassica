class PlantTrial::FungicideTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::FUNGICIDE_ROOT_TERM
  end
end
