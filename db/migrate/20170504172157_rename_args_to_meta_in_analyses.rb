class RenameArgsToMetaInAnalyses < ActiveRecord::Migration
  def change
    rename_column :analyses, :args, :meta
  end
end
