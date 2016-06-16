class AddNoncanonicalTraits < ActiveRecord::Migration
  def up
    Trait.reset_column_information
    Rake::Task['obo:noncanonical_traits'].invoke
  end

  def down
    Trait.where(label: 'BIP/TGAC').destroy_all
  end
end
