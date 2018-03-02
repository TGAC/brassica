class PlantTrial::AntibioticTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::ANTIBIOTIC_ROOT_TERM
  end
end
