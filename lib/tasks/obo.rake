namespace :obo do
  desc 'Loads TaxonomyTerm model'
  task taxonomy: :environment do
    puts "Phase 1: parsing GR_tax ontology as canonical terms."
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

    puts "Phase 2: adding non-canonical, CS terms."
    species_input = %w(alboglabra atlantica bivoniana bourgeaui desnottesii drepanensis nivalis perviridis)
    species_input += %w(juncea? napus? nigra? rapa?)
    species_count = 0
    brassica = TaxonomyTerm.find_by(name: 'Brassica')
    species_input.each do |species|
      tax_term = TaxonomyTerm.find_or_initialize_by(name: "Brassica #{species}")
      save_with_parent(tax_term, brassica)
      species_count += 1
    end if brassica
    puts "  Added #{species_count} species."

    varieties_input = {
      barrelieri: [:sabularia],
      cretica: [:aegaea, :cretica, :laconica],
      deflexa: [:leptocarpa],
      elongata: [:elongata, :integrifolia, :subscaposa],
      fruticulosa: [:djafarensis, :fruticolosa, :fruticulosa, :glaberrima, :pomeliana, :radicata],
      gravinae: [:brachyloma, :djurdjurae],
      incana: [:incana],
      juncea: [:carinata, :cereptana, :cernua, :crispifolia, :folisa, :integlifolia, :integrifolia, 
               :japonica, :juncea, :laevigata, :mangolica, :melanosperma, :mongolica,
               :napiformis, :sareptana, :suberispifolia, :subintegrifolia, :subsareptana, :tsatsai],
      macrocarpa: [:macrocarpa],
      napus: [:biennis, :napus, :oleifera, :pabularia],
      nigra: [:dissecta, :nigra, :orientales, :pseudocampestris, :rigida],
      oleracea: [:acephala, 'acephala?', :viridis, :africana, :capitata, :capitata?,
                 :gemnifera, :sabauda, :sabellica, :tronchuda, :tronchuda?, :alboglabra?],
      rapa: ['Broccoletto Gp', 'Neep Greens Gp', 'Pak Choi Group', :chinensis, :dichotoma,
             :oleifera, :pekinensis, :purpurea, :ruvo, :sylvestris, :trilocularis],
      rapa?: [:rapa?],
      repanda: [:almeriensis, :blancoana, :cadevallii, :cantabrica, :confusa, :maritima, :nudicaulis],
      rupestris: [:glaucescens, :hispida],
      souliei: [:dimorpha],
      spinescens: [:spinescens],
      villosa: [:tinei, :villosa]
    }
    varieties_count = 0
    varieties_input.each do |species, varieties|
      species_term = TaxonomyTerm.find_by(name: "Brassica #{species}")
      varieties.each do |variety|
        tax_term = find_variety('Brassica', species, variety)
        unless tax_term
          # YES, we don't use var. or subsp., since checking those will waste too much time...
          tax_term = TaxonomyTerm.
                     new(name: "Brassica #{species} #{variety}")
        end
        save_with_parent(tax_term, species_term)
        varieties_count += 1
      end if species_term
    end

    puts "  Added #{varieties_count} varieties."


    cultivars_input = {
      juncea: {
        integrifolia: [:crispifolia, :integrifolia, :rugosa]
      },
      napus: {
        napus: [:annua, :biennis, :pabularia],
        oleifera: [:annua, :biennis]
      },
      oleracea: {
        acephala: [:medullosa, :palmifolia, :ramosa, :sabellica, :viridis],
        botrytis: [:botrytis, :italica],
        capitata: [:rubra, :sabauda, :alba]
      },
      rapa: {
        chinensis: [:communis, :parachinensis, :purpuraria, :rosularis],
        oleifera: [:annua, :biennis, :sylvestris],
        pekinensis: [:glabra, :laxa, :pekinensis, :pandurata]
      }
    }
    cultivars_count = 0
    cultivars_input.each do |species, varieties|
      varieties.each do |variety, cultivars|
        variety_term = TaxonomyTerm.
                       find_by(name: variety_names('Brassica', species, variety))
        cultivars.each do |cultivar|
          tax_term = TaxonomyTerm.
                     find_or_initialize_by(name: "#{variety_term.name} #{cultivar}")
          save_with_parent(tax_term, variety_term)
          cultivars_count += 1
        end if variety_term
      end
    end

    puts "  Added #{cultivars_count} cultivars"
  end


  def variety_names(genus, species, subtaxa)
    ["#{genus} #{species} var. #{subtaxa}",
     "#{genus} #{species} subsp. #{subtaxa}",
     "#{genus} #{species} #{subtaxa}"]
  end

  def find_variety(genus, species, subtaxa)
    TaxonomyTerm.
      where(name: variety_names(genus, species, subtaxa)).
      first
  end

  def save_with_parent(term, parent)
    term.canonical = false
    term.label = 'CROPSTORE'
    term.parent = parent
    term.save
    puts "    + [#{term.name}] is_a [#{parent.name}]"
  end
end
