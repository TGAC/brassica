class AddPublishableToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :publishable, :boolean, default: false, null: false
  end
end
