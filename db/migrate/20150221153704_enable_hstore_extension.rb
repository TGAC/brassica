class EnableHstoreExtension < ActiveRecord::Migration
  def change
    enable_extension 'hstore' unless extensions.include?('hstore')
  end
end
