class FixEncoding < ActiveRecord::Migration
  def up
    execute "UPDATE countries SET country_name = 'Åland Islands' WHERE country_name LIKE '%land Islands'"
    execute "UPDATE countries SET country_name = 'Côte d''Ivoire' WHERE country_name LIKE '%te d''Ivoire'"
    execute "UPDATE countries SET country_name = 'Réunion' WHERE country_name LIKE '%union'"
  end

  def down
  end
end
