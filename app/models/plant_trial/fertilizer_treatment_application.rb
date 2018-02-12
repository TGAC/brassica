class PlantTrial::FertilizerTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::FERTILIZER_ROOT_TERM
  end
end
