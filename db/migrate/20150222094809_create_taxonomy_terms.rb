class CreateTaxonomyTerms < ActiveRecord::Migration
  def change
    create_table :taxonomy_terms do |t|
      t.string :label, null: false, index: true
      t.string :name, null: false, index: { unique: true }

      # Parent term - might be null
      t.references :taxonomy_term, index: true

      t.timestamps null: false
    end
  end
end
