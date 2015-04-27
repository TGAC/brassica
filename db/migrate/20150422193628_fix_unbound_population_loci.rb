class FixUnboundPopulationLoci < ActiveRecord::Migration
  def up
    if column_exists?(:population_loci, :plant_population)
      p1 = execute("SELECT id FROM plant_populations WHERE name = 'BolNGDH_01'").first['id']
      p2 = execute("SELECT id FROM plant_populations WHERE name = 'BraVCS3M_01'").first['id']
      execute("UPDATE population_loci SET plant_population_id = #{p1} WHERE plant_population = 'BolNGDH_02'")
      execute("UPDATE population_loci SET plant_population_id = #{p2} WHERE plant_population = 'BraVCS3M_0'")
      execute("ALTER TABLE population_loci DROP COLUMN plant_population")
    end
  end

  def down
  end

end