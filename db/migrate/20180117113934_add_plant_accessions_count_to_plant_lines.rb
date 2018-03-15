class AddPlantAccessionsCountToPlantLines < ActiveRecord::Migration
  def up
    add_column :plant_lines, :plant_accessions_count, :integer, null: false, default: 0

    PlantLine.all.each do |plant_line|
      query = <<-SQL.strip_heredoc
        UPDATE plant_lines
        SET plant_accessions_count = #{plant_line.plant_accessions.count}
        WHERE id = #{plant_line.id}
      SQL

      PlantLine.connection.execute(query)
    end
  end

  def down
    remove_column :plant_lines, :plant_accessions_count, :integer
  end
end
