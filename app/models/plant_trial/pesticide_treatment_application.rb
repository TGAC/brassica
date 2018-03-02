class PlantTrial::PesticideTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::PESTICIDE_ROOT_TERM
  end
end
