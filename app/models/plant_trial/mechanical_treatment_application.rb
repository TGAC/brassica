class PlantTrial::MechanicalTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::MECHANICAL_ROOT_TERM
  end
end
