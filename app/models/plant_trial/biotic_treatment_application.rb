class PlantTrial::BioticTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::BIOTIC_ROOT_TERM
  end
end
