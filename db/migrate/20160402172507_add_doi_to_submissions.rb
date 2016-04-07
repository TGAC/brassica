class AddDoiToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :doi, :string
  end
end
