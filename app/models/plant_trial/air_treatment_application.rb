class PlantTrial::AirTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::AIR_ROOT_TERM
  end
end
