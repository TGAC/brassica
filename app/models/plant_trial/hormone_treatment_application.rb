class PlantTrial::HormoneTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::HORMONE_ROOT_TERM
  end
end
