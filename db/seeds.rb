# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

module Seeds
  def self.create_lamp_types
    lamp_types = [
      "fluorescent tubes",
      "high intensity discharge (HID) lamps",
      "light emitting diodes (LED)"
    ]
    lamp_types.each { |t| LampType.create_with(canonical: true).find_or_create_by!(name: t) }
  end

  def self.create_container_types
    container_types = ["pot", "Petri dish", "well", "tray"]
    container_types.each { |t| ContainerType.create_with(canonical: true).find_or_create_by!(name: t) }
  end

  # Requires plant_treatment_types to be loaded from the ontology.
  def self.create_mechanical_treatment_types
    parent_treatment = PlantTreatmentType.find_by!(term: PlantTreatmentType::MECHANICAL_ROOT_TERM)
    mechanical_treatment_types = ["bending", "wounding"]
    mechanical_treatment_types.each do |t|
      PlantTreatmentType.
        create_with(canonical: false, parent_ids: [parent_treatment.id]).
        find_or_create_by!(name: t)
    end
  end
end

Seeds.create_lamp_types
Seeds.create_container_types
Seeds.create_mechanical_treatment_types
