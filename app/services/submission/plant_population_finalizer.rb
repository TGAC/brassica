class Submission::PlantPopulationFinalizer

  attr_reader :new_plant_lines, :plant_population, :plant_population_lists

  def initialize(submission)
    raise ArgumentError, "Submission already finalized" if submission.finalized?

    self.submission = submission
  end

  def call
    ActiveRecord::Base.transaction do
      create_new_plant_lines
      create_plant_population
      create_plant_population_lists
    end
  end

  private

  attr_accessor :submission

  def create_new_plant_lines
    @new_plant_lines = (submission.content.step03.new_plant_lines || []).map do |attrs|
      attrs = attrs.with_indifferent_access
      taxonomy_term = TaxonomyTerm.find_by!(name: attrs.delete(:taxonomy_term))
      attrs = attrs.merge(
        taxonomy_term_id: taxonomy_term.id,
        date_entered: Date.today,
        data_provenance: submission.content.step04.data_provenance,
        comments: '', # FIXME temporary, remove after dropping not null constraint
      )
      PlantLine.create!(attrs)
    end
  end

  def create_plant_population
    attrs = {
      name: submission.content.step01.name,
      population_owned_by: submission.content.step01.owned_by,
    }

    %i[female_parent_line male_parent_line].each do |parent_line_attr|
      if parent_line = PlantLine.find_by(plant_line_name: submission.content.step03[parent_line_attr])
        attrs.merge!(parent_line_attr => parent_line)
      end
    end

    attrs.merge!(submission.content.step01.to_h)
    attrs.merge!(submission.content.step02.to_h)
    if taxonomy_term = TaxonomyTerm.find_by!(name: submission.content.step02.taxonomy_term)
      attrs.merge!(taxonomy_term: taxonomy_term)
    end

    if population_type = PopulationType.find_by!(population_type: submission.content.step02.population_type)
      attrs.merge!(population_type: population_type)
    end

    attrs.merge!(submission.content.step04.to_h)
    attrs.delete(:name) # FIXME change :name to :plant_population_name in the form
    attrs.delete(:owned_by) # FIXME change to :population_owned_by in the form (or remove entirely)
    @plant_population = PlantPopulation.create!(attrs)
  end

  def create_plant_population_lists
    @plant_population_lists = submission.content.step03.plant_line_list.select(&:present?).map do |plant_line_name|
      plant_line = PlantLine.find_by!(plant_line_name: plant_line_name)
      PlantPopulationList.create!(
        plant_population: plant_population,
        plant_line: plant_line,
        date_entered: Date.today,
        data_provenance: submission.content.step04.data_provenance,
        entered_by_whom: submission.user.login,
        comments: '', # FIXME temporary, remove after dropping not null constraint
      )
    end
  end
end
