require 'rails_helper'

RSpec.describe Search, :elasticsearch, :dont_clean_db do

  before(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)

    DatabaseCleaner.clean_with :truncation

    tt1 = create(:taxonomy_term, name: 'Tooo')
    tt2 = create(:taxonomy_term, name: 'Taaaaz')

    create(:plant_variety, plant_variety_name: "Pvoo")
    create(:plant_variety, plant_variety_name: "Pvoobar")
    create(:plant_variety, plant_variety_name: "Pvoobarbaz")

    create(:plant_line, plant_line_name: "Ploo",
                        common_name: "Ploo cabbage",
                        taxonomy_term: TaxonomyTerm.first)
    create(:plant_line, plant_line_name: "Ploobar",
                        common_name: "Ploobar cabbage",
                        taxonomy_term: TaxonomyTerm.second)
    create(:plant_line, plant_line_name: "Ploobarbaz",
                        common_name: "Ploobarbaz cabbage",
                        taxonomy_term: TaxonomyTerm.second)

    pp1 = create(:plant_population, name: 'Ppoo',
                                    taxonomy_term: tt1,
                                    male_parent_line: nil,
                                    female_parent_line: nil)
    pp2 = create(:plant_population, name: 'Ppoobar',
                                    taxonomy_term: TaxonomyTerm.second,
                                    male_parent_line: nil,
                                    female_parent_line: nil)
    create(:plant_population, name: 'Ppoobarbaz',
                              taxonomy_term: TaxonomyTerm.second,
                              male_parent_line: nil,
                              female_parent_line: nil)

    pr1 = create(:probe, probe_name: 'probeno1',
                         clone_name: 'Attack of clones',
                         taxonomy_term: tt1)
    pr2 = create(:probe, probe_name: 'some other probe',
                         clone_name: 'Gamma clone',
                         taxonomy_term: tt2)
    pi1 = create(:primer, primer: 'primerA',
                          description: 'Describing primer A')
    pi2 = create(:primer, primer: 'primerX',
                          description: 'No description of primer provided')
    ma1 = create(:marker_assay, marker_assay_name: 'wisc_CHS28aX_a00',
                                marker_type: 'marker type',
                                primer_a: pi1,
                                primer_b: pi2,
                                probe: pr1)
    ma2 = create(:marker_assay, marker_assay_name: 'other marker assay name',
                                marker_type: 'autre chose',
                                primer_a: nil,
                                primer_b: pi2,
                                probe: pr1)
    plo1 = create(:population_locus, mapping_locus: 'cnu_m182a',
                                     marker_assay: ma1,
                                     plant_population: pp1)
    plo2 = create(:population_locus, mapping_locus: 'pO153E2NP',
                                     marker_assay: ma2,
                                     plant_population: pp1)
    lg1 = create(:linkage_group, consensus_group_assignment: 'consensus1',
                                 linkage_group_label: 'linkage group label')
    lg2 = create(:linkage_group, consensus_group_assignment: 'no consensus',
                                 linkage_group_label: 'group2')
    lm1 = create(:linkage_map, linkage_map_label: 'linkage map label',
                               map_version_no: '1',
                               plant_population: pp1)
    lm2 = create(:linkage_map, linkage_map_label: 'linkage map label 2',
                               map_version_no: '333',
                               plant_population: pp1)
    mp1 = create(:map_position, map_position: '102.8',
                                linkage_group: lg1,
                                population_locus: plo1)
    mp2 = create(:map_position, map_position: '54.2',
                                linkage_group: lg2,
                                population_locus: plo2)
    create(:map_locus_hit, atg_hit_seq_source: 'GATTACA',
                           population_locus: plo1,
                           map_position: mp1,
                           linkage_map: lm1)
    create(:map_locus_hit, atg_hit_seq_source: 'TTTTTTT',
                           population_locus: plo2,
                           map_position: mp2,
                           linkage_map: lm2)
    create(:plant_trial, project_descriptor: 'Project X',
                         plant_population: pp1)
    create(:plant_trial, project_descriptor: 'Yet Another Big Success',
                         plant_population: pp2)
    td1 = create(:trait_descriptor, descriptor_name: 'leafy leaf')
    td2 = create(:trait_descriptor, descriptor_name: 'uranium uptake')
    ptd1 = create(:processed_trait_dataset, trait_descriptor: td1)
    ptd2 = create(:processed_trait_dataset, trait_descriptor: td2)
    create(:qtl, outer_interval_start: '55.7',
                 processed_trait_dataset: ptd1)
    create(:qtl, outer_interval_start: '347.11',
                 processed_trait_dataset: ptd2)

    # Special cases
    create(:plant_line, plant_line_name: "123@456")

    # FIXME without sleep ES is not able to update index in time
    sleep 1
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "#plant_populations" do
    it "finds PP by :name" do
      expect(Search.new("Ppoo").plant_populations.count).to eq 3
      expect(Search.new("Ppoobar").plant_populations.count).to eq 2
      expect(Search.new("Ppoobarbaz").plant_populations.count).to eq 1
      expect(Search.new("Ppoobarbaz").plant_populations.first.id.to_i).
        to eq PlantPopulation.find_by!(name: 'Ppoobarbaz').id
    end

    it "finds PPs by taxonomy_term.name" do
      results = Search.new(TaxonomyTerm.first.name).plant_populations
      expect(results.count).to eq 1

      results = Search.new(TaxonomyTerm.second.name).plant_populations
      expect(results.count).to eq 2
    end
  end

  describe "#plant_varieties" do
    it "finds PV by :plant_variety_name" do
      expect(Search.new("Pvoo").plant_varieties.count).to eq 3
      expect(Search.new("Pvoobar").plant_varieties.count).to eq 2
      expect(Search.new("Pvoobarbaz").plant_varieties.count).to eq 1
      expect(Search.new("Pvoobarbaz").plant_varieties.first.id.to_i).
        to eq PlantVariety.find_by!(plant_variety_name: 'Pvoobarbaz').id
    end
  end

  describe "#plant_lines" do
    it "finds PL by :plant_line_name" do
      expect(Search.new("Ploo").plant_lines.count).to eq 3
      expect(Search.new("Ploobar").plant_lines.count).to eq 2
      expect(Search.new("Ploobarbaz").plant_lines.count).to eq 1
      expect(Search.new("Ploobarbaz").plant_lines.first.id.to_i).
        to eq PlantLine.find_by!(plant_line_name: 'Ploobarbaz').id
    end

    it "finds PL by fragment of :plant_line_name" do
      result = Search.new("lo").plant_lines.select do |pl|
        pl.plant_line_name.include? 'lo'
      end
      expect(result.count).to eq 3
      expect(Search.new("looba").plant_lines.count).to eq 2
      expect(Search.new("loobarba").plant_lines.count).to eq 1
      expect(Search.new("loobarbaz").plant_lines.first.id.to_i).
        to eq PlantLine.find_by!(plant_line_name: 'Ploobarbaz').id
    end

    it "finds PLs by taxonomy_term.name" do
      results = Search.new(TaxonomyTerm.first.name).plant_lines
      expect(results.count).to eq 1

      results = Search.new(TaxonomyTerm.second.name).plant_lines
      expect(results.count).to eq 2
    end
  end

  describe '#map_locus_hits' do
    it 'finds MLH by :atg_hit_seq_source' do
      expect(Search.new("TT").map_locus_hits.count).to eq 2
      expect(Search.new("ATT").map_locus_hits.count).to eq 1
    end

    it 'finds MLH by exact map_position.map_position' do
      expect(Search.new("102.8").map_locus_hits.count).to eq 1
    end

    it 'does not find MLH by inexact map_position.map_position' do
      pending 'This test should pass if #253 is fixed'
      expect(Search.new("2.8").map_locus_hits.count).to eq 0
    end
  end

  describe '#map_positions' do
    it 'finds MP by :map_position' do
      expect(Search.new("102.8").map_positions.count).to eq 1
    end

    it 'finds MP by linkage_group.linkage_group_label' do
      expect(Search.new("group la").map_positions.count).to eq 1
      expect(Search.new("group").map_positions.count).to eq 2
    end
  end

  describe '#population_loci' do
    it 'finds PLoci by :mapping_locus' do
      expect(Search.new("pO153").population_loci.count).to eq 1
    end

    it 'finds PLoci by marker_assays.marker_assay_name' do
      expect(Search.new("CHS28aX").population_loci.count).to eq 1
      expect(Search.new("CHS28aXa").population_loci.count).to eq 0
    end
  end

  describe '#linkage_maps' do
    it 'finds LM by :map_version_no' do
      expect(Search.new("333").linkage_maps.count).to eq 1
    end

    it 'finds LM by plant_population.name' do
      expect(Search.new("Ppoo").linkage_maps.count).to eq 2
    end

    it 'finds LM by taxonomy_term.name' do
      expect(Search.new("Too").linkage_maps.count).to eq 2
    end
  end

  describe '#linkage_groups' do
    it 'finds LG by :consensus_group_assignment' do
      expect(Search.new("sensus1").linkage_groups.count).to eq 1
    end
  end

  describe '#marker_assays' do
    it 'finds MA by :marker_type' do
      expect(Search.new("autre chose").marker_assays.count).to eq 1
    end

    it 'finds MA by primer_a.primer sans case' do
      expect(Search.new("PrimerA").marker_assays.count).to eq 1
    end
  end

  describe '#primers' do
    it 'finds PI by :description' do
      expect(Search.new("Describing").primers.count).to eq 1
    end
  end

  describe '#probes' do
    it 'finds PR by :clone_name' do
      expect(Search.new("Gamma").probes.count).to eq 1
    end

    it 'finds PR by taxonomy_term.name' do
      expect(Search.new("Tooo").probes.count).to eq 1
    end
  end

  describe '#plant_trials' do
    it 'finds PT by :project_descriptor' do
      expect(Search.new("Yet Another").plant_trials.count).to eq 1
    end

    it 'finds PT by plant_population.name' do
      expect(Search.new("Ppoob").plant_trials.count).to eq 1
    end
  end

  describe '#qtl' do
    it 'finds QTL by :outer_interval_start' do
      expect(Search.new('347.11').qtl.count).to eq 1
    end

    it 'finds QTL by trait_descriptor.descriptor_name' do
      expect(Search.new("leafy").qtl.count).to eq 1
    end
  end

  describe '#trait_descriptors' do
    it 'finds TD by :descriptor_name' do
      expect(Search.new("uranium").trait_descriptors.count).to eq 1
    end
  end


  describe "#counts" do
    it "returns proper counts" do
      counts = Search.new("").counts
      expect(counts[:plant_lines]).to eq PlantLine.count
      expect(counts[:plant_populations]).to eq PlantPopulation.count
      expect(counts[:plant_varieties]).to eq PlantVariety.count
      expect(counts[:map_locus_hits]).to eq MapLocusHit.count
      expect(counts[:map_positions]).to eq MapPosition.count
      expect(counts[:population_loci]).to eq PopulationLocus.count
      expect(counts[:linkage_groups]).to eq LinkageGroup.count
      expect(counts[:linkage_maps]).to eq LinkageMap.count
      expect(counts[:marker_assays]).to eq MarkerAssay.count
      expect(counts[:primers]).to eq Primer.count
      expect(counts[:probes]).to eq Probe.count
      expect(counts[:plant_trials]).to eq PlantTrial.count
      expect(counts[:qtl]).to eq Qtl.count
      expect(counts[:trait_descriptors]).to eq TraitDescriptor.count
    end

    context "special cases" do
      it "returns proper counts" do
        expect(Search.new("123").counts).to include(plant_lines: 1)
        expect(Search.new("123@").counts).to include(plant_lines: 1)
        expect(Search.new("@456").counts).to include(plant_lines: 1)
        expect(Search.new("123@456").counts).to include(plant_lines: 1)
      end
    end
  end

  describe "query transformation" do
    examples = {
      'foo' => '*foo*',
      'foo@example.com' => 'foo@example.com',
      'foo:bar' => '*foo\:bar*'
    }

    examples.each do |input_query, output_query|
      context "given #{input_query}" do
        it "transforms it to #{output_query}" do
          expect(Search.new(input_query).query).to eq output_query
        end
      end
    end
  end
end
