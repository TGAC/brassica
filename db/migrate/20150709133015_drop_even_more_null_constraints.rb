class DropEvenMoreNullConstraints < ActiveRecord::Migration
  def up
    execute "ALTER TABLE primers ALTER COLUMN sequence_id DROP NOT NULL"
    execute "ALTER TABLE primers ALTER COLUMN sequence_source_acronym DROP NOT NULL"

    execute "ALTER TABLE qtl ALTER COLUMN additive_effect DROP NOT NULL"

    execute "ALTER TABLE map_positions ALTER COLUMN mapping_locus DROP NOT NULL"
  end

  def down
  end
end
