namespace :obo do
  desc 'Parses a OBO ontology and loads to TaxonomyTerm model'
  task taxonomy: :environment do
    taxonomy = Obo::Parser.new 'db/data/GR_tax-ontology-Brassica.obo.txt'
    total_count = 0
    root_count = 0
    taxonomy.elements.each do |term|
      tags = term.tagvalues
      # Pass the Header and make sure the term has an ID
      next unless term.is_a?(Obo::Stanza) && term.name == 'Term' && tags['id'][0]
      total_count += 1
      tax_term = TaxonomyTerm.find_or_initialize_by(label: tags['id'][0])
      tax_term.name = tags['name'][0]
      tags['is_a'].each do |parent_label|
        parent = TaxonomyTerm.find_by(label: parent_label)
        tax_term.parent = parent if parent
      end
      root_count += 1 unless tax_term.parent
      tax_term.save
    end
    puts "Done. Parsed #{total_count} terms, including #{root_count} root(s)."
  end
end
