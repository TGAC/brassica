class Search

  attr_accessor :query

  def initialize(query)
    self.query = prepare_query(query.dup)
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
      linkage_groups: linkage_groups.count
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
      linkage_groups: linkage_groups
    }
  end

  def plant_populations
    PlantPopulation.search(query, size: PlantPopulation.count)
  end

  def plant_lines
    PlantLine.search(query, size: PlantLine.count)
  end

  def plant_varieties
    PlantVariety.search(query, size: PlantVariety.count)
  end

  def map_locus_hits
    MapLocusHit.search(query, size: MapLocusHit.count)
  end

  def map_positions
    MapPosition.search(query, size: MapPosition.count)
  end

  def population_loci
    PopulationLocus.search(query, size: PopulationLocus.count)
  end

  def linkage_groups
    LinkageGroup.search(query, size: LinkageGroup.count)
  end

  def linkage_maps
    LinkageMap.search(query, size: LinkageMap.count)
  end

  private

  def prepare_query(query)
    query = escape_query_special_chars(query)
    add_query_wildcards(query)
  end

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
end
