class PlantTrial::ChemicalTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::CHEMICAL_ROOT_TERM
  end
end
