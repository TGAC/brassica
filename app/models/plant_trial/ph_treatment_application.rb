class PlantTrial::PhTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::PH_ROOT_TERM
  end
end
