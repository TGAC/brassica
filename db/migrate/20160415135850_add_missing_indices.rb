class AddMissingIndices < ActiveRecord::Migration
  def up
    ActiveRecord::Base.send(:subclasses).each do |model|
      next if model.table_name == 'traits'
      if (model.column_names & ['user_id', 'published']).length == 2
        unless index_exists?(model.table_name.to_sym, :user_id)
          add_index(model.table_name.to_sym, :user_id)
        end
        unless index_exists?(model.table_name.to_sym, :published)
          add_index(model.table_name.to_sym, :published)
        end
      end
    end
  end

  def down
    ActiveRecord::Base.send(:subclasses).each do |model|
      if (model.column_names & ['user_id', 'published']).length == 2
        if index_exists?(model.table_name.to_sym, :user_id)
          remove_index(model.table_name.to_sym, :user_id)
        end
        if index_exists?(model.table_name.to_sym, :published)
          remove_index(model.table_name.to_sym, :published)
        end
      end
    end
  end
end
