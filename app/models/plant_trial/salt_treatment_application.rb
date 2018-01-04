class PlantTrial::SaltTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::SALT_ROOT_TERM
  end
end
