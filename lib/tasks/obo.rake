require "obo"
require "obo/plant_treatment_type_importer"
require "obo/topological_factor_importer"

namespace :obo do
  desc "Load PlantTreatmentType model"
  task plant_treatment_types: :environment do
    Obo::PlantTreatmentTypeImporter.new("db/data/peco.obo").import_all
  end

  desc "Load TopologicalFactor model"
  task topological_factors: :environment do
    Obo::TopologicalFactorImporter.new("db/data/Crop_Experiment_Ontology.obo").import_all
  end

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
      tax_term.save!
    end
    puts "Done. Parsed #{total_count} terms, including #{root_count} root(s)."

    puts "Phase 2: adding non-canonical, CS terms."
    genera_input = %w(X_Brassicoraphanus)
    genera_count = 0
    genera_input.each do |genus|
      tax_term = TaxonomyTerm.find_or_initialize_by(name: genus)
      save_with_parent(tax_term, nil)
      genera_count += 1
    end
    puts "  Added #{genera_count} genera."

    species_input = %w(alboglabra atlantica bivoniana bourgeaui desnottesii drepanensis nivalis perviridis)
    species_input += %w(juncea? napus? nigra? rapa?)
    species_input += ['rapa and napus']
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
      napus: [:biennis, :oleifera, :pabularia],
      nigra: [:dissecta, :nigra, :orientales, :pseudocampestris, :rigida],
      oleracea: [:acephala, 'acephala?', :viridis, :africana, :capitata, :capitata?,
                 :gemnifera, :sabauda, :sabellica, :tronchuda, :tronchuda?, :alboglabra?],
      rapa: ['Broccoletto Gp', 'Neep Greens Gp', 'Pak Choi Group', :chinensis, :dichotoma,
             :oleifera, :pekinensis, :purpurea, :ruvo, :sylvestris, :trilocularis, :napobrassica],
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

  task plant_parts: :environment do
    puts "Parsing Plant Ontology as canonical PP terms."
    part_terms = Obo::Parser.new 'db/data/po.obo'
    total_count = 0
    part_terms.elements.each do |term|
      tags = term.tagvalues
      # Pass the Header and make sure the term has an ID
      next unless term.is_a?(Obo::Stanza) && term.name == 'Term' && tags['id'][0]
      # Take only plant_anatomy elements
      next unless tags['namespace'][0] == 'plant_anatomy'
      # Take only elements that are not obsolete
      next if tags['is_obsolete'][0]

      PlantPart.find_or_create_by!(label: tags['id'][0]) do |plant_part|
        plant_part.plant_part = tags['name'][0]
        plant_part.description = tags['def'][0]
        plant_part.data_provenance = 'Plant ontology v. releases/2016-05-19'
        plant_part.canonical = true
      end
      total_count += 1
    end
    puts "Done. Parsed #{total_count} terms."
  end

  task traits: :environment do
    puts "Phase 1: Parsing Trait Ontology as canonical Trait terms."
    trait_terms = Obo::Parser.new 'db/data/to.obo'
    total_new_count = 0
    total_mapped_count = 0
    total_old_count = 0
    trait_terms.elements.each do |term|
      tags = term.tagvalues
      # Pass the Header and make sure the term has an ID
      next unless term.is_a?(Obo::Stanza) && term.name == 'Term' && tags['id'][0]
      # Take only elements that are not obsolete
      next if tags['is_obsolete'][0]

      Trait.find_or_create_by!(label: tags['id'][0]) do |trait|
        trait.name = tags['name'][0]
        trait.description = tags['def'][0]
        trait.data_provenance = 'Trait ontology v. releases/2015-11-12'
        trait.canonical = true
      end
      total_new_count += 1
    end
    puts "Done. Parsed and created #{total_new_count} TO terms."

    puts "Phase 2: Relating TraitDescriptors to Traits with curation."
    trait_map = {
      'seed oil content' => 'TO:0000604',  # fat and essential oil content
      'oleic acid content' => 'TO:0005002',
      'shoot phosphorus content (P)' => 'TO:0001024',
      'shoot nitrogen content (N)' => 'TO:0020093',
      'shoot manganese content (Mn)' => 'TO:0020091',
      'shoot iron content (Fe)' => 'TO:0020089',
      'shoot potassium content (K)' => 'TO:0000609',
      'shoot copper content (Cu)' => 'TO:0020092',
      'shoot carbon content (C)' => 'TO:0000466',
      'shoot sodium content (Na)' => 'TO:0000608',
      'shoot zinc content (Zn)' => 'TO:0020090',
      'phosphorus utilization efficiency (P)' => 'TO:0000627',
      'seed mature time' => 'TO:0000469',
      'seed yield per plant' => 'TO:0000445',
      'seed weight' => 'TO:0000181',
      'YIELD weight (g) - 5 plant average' => 'TO:0000371',
      'plant height' => 'TO:0000207',
      'flowering time' => 'TO:0000344',
      'Early leaf chlorophyll levels' => 'TO:0000495',
      'Early milled leaves chlorophyll a' => 'TO:0000293',
      'Early milled leaves chlorophyll b' => 'TO:0000295',
      'Early leaf NO3-N (ug/g)' => 'TO:0020094',
      'PO4-P (mg/kg)' => 'TO:0020102',
      'Seed Count - 5 sample average' => 'TO:0000445',
      'average seed width - 5 sample average' => 'TO:0000149',
      'average seed length - 5 sample average' => 'TO:0000395'
    }
    new_name_map = {
      'erucic acid content' => 'Seed C22:1',
      'siliquae per plant' => 'Siliquae per plant',
      'glucosinolate content' => 'Seed glucosinolate',
      'seed oil content' => 'Seed oil content', # !!! has a TO term, see #420
      'oleic acid content' => 'Seed C18:1', # !!! has a TO term, see #420
      'siliquae of main inflorescence' => 'Siliquae of main inflorescence',
      'shoot phosphorus content	(P)' => 'Shoot P', # !!! has a TO term, see #420
      'shoot nitrogen content (N)' => 'Shoot N', # !!! has a TO term, see #420
      'shoot boron content (B)' => 'Shoot B',
      'shoot manganese content (Mn)' => 'Shoot Mn', # !!! has a TO term, see #420
      'shoot iron content (Fe)' => 'Shoot Fe', # !!! has a TO term, see #420
      'shoot potassium content (K)' => 'Shoot K', # !!! has a TO term, see #420
      'shoot magnesium content (Mg)' => 'Shoot Mg',
      'shoot copper content (Cu)' => 'Shoot Cu', # !!! has a TO term, see #420
      'shoot carbon content (C)' => 'Shoot C', # !!! has a TO term, see #420
      'shoot sodium content (Na)' => 'Shoot Na', # !!! has a TO term, see #420
      'shoot zinc content (Zn)' => 'Shoot Zn', # !!! has a TO term, see #420
      'shoot calcium content (Ca)' => 'Shoot Ca',
      'phosphorus efficiency ratio (P)' => 'PER',
      'physiological phosphorus use efficiency (P)' => 'PPUE',
      'agronomic phosphorus use efficiency (P)' => 'APE',
      'phosphorus uptake efficiency (P)' => 'PUpE',
      'phosphorus utilization efficiency (P)' => 'PUtE', # !!! has a TO term, see #420
      'potassium uptake efficiency (K)' => 'KUpE',
      'seed mature time' => 'Seed mature time', # !!! has a TO term, see #420
      'number of first branch' => 'Number of first branches',
      'seed yield per plant' => 'Seed yield', # !!! has a TO term, see #420
      'seed weight' => 'Seed weight', # !!! has a TO term, see #420
      'YIELD weight (g) - 5 plant average' => 'Yield', # !!! has a TO term, see #420
      'straw yield' => 'Straw yield',
      'plant height' => 'Plant height', # !!! has a TO term, see #420
      'canopy leaf bagged fresh weight' => 'Canopy leaf fresh weight plus bag',
      'shoot fresh weight' => 'Shoot fresh weight',
      'early leaf bagged fresh weight' => 'Early leaf fresh weight plus bag',
      'canopy leaf bagged dry weight' => 'Canopy leaf dry weight plus bag',
      'early leaf bagged dry weight' => 'Early leaf dry weight plus bag',
      'shoot percent dry weight' => 'Shoot dry weight',
      'shoot dry weight' => 'Shoot dry weight',
      'host response to Peronospora parasitica' => 'Host response to Peronospora parasitica',
      'host response to Brevicoryne brassicae' => 'Host response to Brevicoryne brassicae',
      'host response to Albugo candida' => 'Host response to Albugo candida',
      'flowering time' => 'Start of flowering' # !!! has a TO term, see #420
    }
    TraitDescriptor.all.each do |trait_descriptor|
      trait = if trait_map[trait_descriptor.descriptor_name]
                trait = Trait.find_by_label(trait_map[trait_descriptor.descriptor_name.strip])
                raise "Trait label #{trait_map[trait_descriptor.descriptor_name.strip]} not found in TO table!" unless trait
                total_mapped_count += 1
                trait
              else
                trait = Trait.find_or_create_by!(name: trait_descriptor.descriptor_name) do |trait|
                  trait.label = 'CROPSTORE'
                  trait.data_provenance = 'CROPSTORE'
                  trait.canonical = false
                end
                total_old_count += 1
                trait
              end
      trait_descriptor.update_column(:trait_id, trait.id)
    end
    puts "Done. Created #{total_old_count} non-canonical TO terms from TD records and mapped #{total_mapped_count} TDs to canonical TO terms."
  end

  task noncanonical_traits: :environment do
    # This task loads trait curated by Annemarie from other sources, which are not present in the Trait Ontology
    puts "Creating Trait records for non-TO terms provided by Annemarie."
    total_new_count = 0

    ['Straw yield', 'Flowering period', 'End of flowering', 'Adult Phradis Sp.', 'Adult Tersilochus heterocerus',
     'Adult Tersilochus Sp. (other than heterocerus)', 'Adult Pteromalidae Sp.', 'Adult other Parasitoid', 'Pollen beetle adult',
     'Light leaf spot', 'Stem canker', 'Sclerotinia', 'Early leaf carotenoids', 'Canopy leaf Chl', 'Canopy leaf Chl-a', 'Canopy leaf Chl-b',
     'Canopy leaf carotenoids', 'Stem stiffness', 'Seed shatter', 'Pod maturity', 'Branch numbers', 'Canopy leaf NO3-', 'Seed NO3-', 'Seed Li',
     'Seed  Sr', 'Seed S', 'Seed Ti', 'Seed Al', 'Seed V', 'Seed Cr', 'Seed Co', 'Seed Ni', 'Seed As', 'Seed Se', 'Seed Rb', 'Seed Mo',
     'Seed Ag', 'Seed Cd', 'Seed Cs', 'Seed Ba', 'Seed Pb', 'Seed U', 'Seed F', 'Seed Cl', 'Seed Malate', 'Seed Sulfate', 'Seed C14:0',
     'Seed C16:0', 'Seed C18:0', 'Seed C18:2', 'Seed C18:3', 'Seed C20:0', 'Seed C20:1', 'Seed C20:2', 'Seed C22:0',
     'Pod and stem Alkane-functional group content', 'Pod and stem prim. Alkohol functional group content',
     'Pod and stem Fatty acids functional group content', 'Pod and stem  2dary Alkohol functional group content',
     'Pod and stem Ketone functional group content', 'Pod and stem branched alcyl-chain content', 'Pod and stem Aldehyde functional group content',
     'Pod and stem wax content', 'Seed δ-tocopherol', 'Seed γ-tocopherol', 'Seed α-tocopherol', 'Seed moisture content', 'Seed protein content',
     'Stem weevil count', 'Seed weevil count', 'Seed area', 'Shoot fresh weight at high N', 'Shoot fresh weight at low N',
     'Shoot organic N at high N', 'Shoot organic N at low N', 'Shoot Nitrate at high N', 'Shoot Nitrate at low N', 'Shoot P at high N',
     'Shoot P at low N', 'Shoot K at high N', 'Shoot K at low N', 'Shoot Na at high N', 'Shoot Na at low N', 'Shoot Mn at high N',
     'Shoot Mn at low N', 'Shoot  Ca at high N', 'Shoot Ca  at low N', 'Shoot Mg at high N', 'Shoot Mg at low N', 'Seed Brassicasterol',
     'Seed Campesterol diunsaturated', 'Seed Campesterol', 'Seed Stigmasterol', 'Seed β-Sitosterol', 'Seed Avenasterol', 'Seed Cycloartenol',
     'Seed Sterol', 'Bolting time', 'Budding time', 'Primary branch angle', 'Number of pods', 'Lower stem length', 'Pedicel angle',
     'Pedicel length', 'Pod angle', 'Pod length', 'Pod width', 'Stem width', 'Pigeon damage', 'Flowering phenology', 'Plant weight', 'Seed P',
     'Seed B', 'Seed Mn', 'Seed Fe', 'Seed K', 'Seed Mg', 'Seed Cu', 'Seed Na', 'Seed Zn', 'Seed Ca', 'Canopy leaf P', 'Canopy leaf Kjeldal N',
     'Canopy leaf K', 'Canopy leaf Mn', 'Canopy leaf Mg', 'Canopy leaf Na', 'Canopy leaf Ca', 'Early leaf P', 'Early leaf Kjeldahl N',
     'Early leaf Mn', 'Early leaf K', 'Early leaf Mg', 'Early leaf Na', 'Early leaf Ca', 'Seed number'].each do |term_name|

      Trait.create!(
        name: term_name,
        label: 'BIP/TGAC',
        data_provenance: 'BIP/TGAC',
        canonical: false
      )
      total_new_count += 1
    end
    puts "Done. Created #{total_new_count} non-canonical Trait terms."
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
    term.save!
    puts "    + [#{term.name}] is_a [#{parent.name}]" if parent
  end
end
