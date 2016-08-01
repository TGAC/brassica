class AddImagesTrait < ActiveRecord::Migration
  def up
    insert = "INSERT INTO traits(label, name, description, canonical, data_provenance, created_at, updated_at)
              VALUES ('BIP/EI',
                      'images',
                      'This trait is used as placeholder for referring to image raw data stored and cross-linked with another resource',
                      FALSE,
                      'BIP/EI',
                      '#{Time.now.to_s(:db)}',
                      '#{Time.now.to_s(:db)}')"
    execute insert
  end

  def down
    execute("DELETE FROM traits WHERE name='images'")
  end
end
