class AddFinishedAtToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :finished_at, :datetime
  end
end
