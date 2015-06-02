class Search

  attr_accessor :query, :wildcarded_query

  def initialize(query)
    query = escape_query_special_chars(query.dup)

    self.query = query
    self.wildcarded_query = add_query_wildcards(query)
  end

  def counts
    {
      plant_populations: plant_populations.count,
      plant_lines: plant_lines.count,
      plant_varieties: plant_varieties.count,
      map_locus_hits: map_locus_hits.count,
      map_positions: map_positions.count,
      population_loci: population_loci.count,
      linkage_maps: linkage_maps.count,
      linkage_groups: linkage_groups.count,
      marker_assays: marker_assays.count,
      primers: primers.count,
      probes: probes.count,
      plant_trials: plant_trials.count,
      qtl: qtl.count,
      trait_descriptors: trait_descriptors.count
    }
  end

  def all
    {
      plant_populations: plant_populations,
      plant_lines: plant_lines,
      plant_varieties: plant_varieties,
      map_locus_hits: map_locus_hits,
      map_positions: map_positions,
      population_loci: population_loci,
      linkage_maps: linkage_maps,
      linkage_groups: linkage_groups,
      marker_assays: marker_assays,
      primers: primers,
      probes: probes,
      plant_trials: plant_trials,
      qtl: qtl,
      trait_descriptors: trait_descriptors
    }
  end

  def plant_populations
    PlantPopulation.search(wildcarded_query, size: PlantPopulation.count)
  end

  def plant_lines
    PlantLine.search(wildcarded_query, size: PlantLine.count)
  end

  def plant_varieties
    PlantVariety.search(wildcarded_query, size: PlantVariety.count)
  end

  def map_locus_hits
    MapLocusHit.search(wildcarded_query, size: MapLocusHit.count)
  end

  def map_positions
    MapPosition.search(wildcarded_query, size: MapPosition.count)
  end

  def population_loci
    PopulationLocus.search(wildcarded_query, size: PopulationLocus.count)
  end

  def linkage_groups
    LinkageGroup.search(wildcarded_query, size: LinkageGroup.count)
  end

  def linkage_maps
    LinkageMap.search(wildcarded_query, size: LinkageMap.count)
  end

  def marker_assays
    MarkerAssay.search(wildcarded_query, size: MarkerAssay.count)
  end

  def primers
    Primer.search(wildcarded_query, size: Primer.count)
  end

  def probes
    Probe.search(wildcarded_query, size: Probe.count)
  end

  def plant_trials
    PlantTrial.search(wildcarded_query, size: PlantTrial.count)
  end

  def qtl
    if numeric_query?
      Qtl.search(
        filter: {
          or: Qtl.numeric_columns.map { |column|
            { term: { column => query } }
          }
        },
        size: Qtl.count
      )
    else
      Qtl.search(wildcarded_query, size: Qtl.count)
    end
  end

  def trait_descriptors
    TraitDescriptor.search(wildcarded_query, size: TraitDescriptor.count)
  end

  private

  def escape_query_special_chars(query)
    special_chars.each { |chr| query.gsub!(chr, "\\#{chr}") }
    query
  end

  def add_query_wildcards(query)
    query.include?("@") ? query : "*#{query}*"
  end

  def special_chars
    %w(: [ ] ( ) { } + - ~ < = > ^ \ / && || ! " * ?)
  end

  def numeric_query?
    query =~ /\A-?\d+(\.\d+)?\z/
  end
end
