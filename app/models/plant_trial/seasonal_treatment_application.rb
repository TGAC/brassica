class PlantTrial::SeasonalTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::SEASONAL_ROOT_TERM
  end
end
