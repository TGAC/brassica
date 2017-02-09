class MakeEstablishingOrganisationMandatory < ActiveRecord::Migration
  def up
    execute("UPDATE plant_populations SET establishing_organisation = '' WHERE establishing_organisation IS NULL")
    execute("ALTER TABLE plant_populations ALTER COLUMN establishing_organisation SET NOT NULL")
  end

  def down
    execute("ALTER TABLE plant_populations ALTER COLUMN establishing_organisation DROP NOT NULL")
  end
end
