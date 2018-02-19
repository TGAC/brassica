# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

module Seeds
  def self.create_canonical_plant_treatment_types
    Rake::Task["obo:plant_treatment_types"].invoke
  end

  def self.create_non_canonical_plant_treatment_types
    root_type = PlantTreatmentType.find_by!(term: PlantTreatmentType::ROOT_TERM)
    PlantTreatmentType.
      create_with(canonical: false, parent_ids: [root_type.id]).
      find_or_create_by!(name: "Soil temperature treatment", term: PlantTreatmentType::SOIL_TEMPERATURE_ROOT_TERM)

    PlantTreatmentType.
      create_with(canonical: false, parent_ids: [root_type.id]).
      find_or_create_by!(name: "Other treatment", term: PlantTreatmentType::OTHER_ROOT_TERM)

    mechanical_root_type = PlantTreatmentType.find_by!(term: PlantTreatmentType::MECHANICAL_ROOT_TERM)
    mechanical_treatment_types = ["bending", "wounding"]
    mechanical_treatment_types.each do |t|
      PlantTreatmentType.
        create_with(canonical: false, parent_ids: [mechanical_root_type.id]).
        find_or_create_by!(name: t)
    end
  end

  def self.create_canonical_measurement_units
    Rake::Task["obo:measurement_units"].invoke
  end

  def self.create_non_canonical_measurement_units
    non_canonical_units = {
      "mol m−2s−1" => "A photosynthetic photon flux density (PPDF) unit.",
      "μmol m–2 s–1" => "A photosynthetic photon flux density (PPDF) unit.",
      "mole per mole" => "A light quality unit denoting ratio of different kinds of
                          light, e.g. red light to far red light ratio (XEO:00036).",
      "gram per gram dry weight" => "Defines the potential energy of water per unit mass
                                     of water in the soil (XEO:00126).",
      "S m–1" => "An electrical condictivity unit.",
      "dS m–1" => "An electrical condictivity unit.",
      "count per plot" => "Sowing density unit.",
      "pascal per square meter" => "Soil penetration strength unit"
    }

    non_canonical_units.each do |name, description|
      MeasurementUnit.
        create_with(canonical: false).
        find_or_create_by!(name: name, description: description)
    end
  end

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
end

unless Rails.env.test?
  Seeds.create_lamp_types
  Seeds.create_container_types
  Seeds.create_canonical_plant_treatment_types
  Seeds.create_non_canonical_plant_treatment_types
  Seeds.create_canonical_measurement_units
  Seeds.create_non_canonical_measurement_units
end
