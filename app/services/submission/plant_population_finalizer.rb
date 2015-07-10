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
      update_submission
    end
    submission.finalized?
  end

  private

  attr_accessor :submission

  def create_new_plant_lines
    @new_plant_lines = (submission.content.step03.new_plant_lines || []).map do |attrs|
      attrs = attrs.with_indifferent_access
      taxonomy_term = TaxonomyTerm.find_by!(name: attrs.delete(:taxonomy_term))
      attrs = attrs.merge(
        taxonomy_term_id: taxonomy_term.id,
        entered_by_whom: submission.user.full_name,
        date_entered: Date.today,
        user: submission.user
      )

      if attrs[:plant_variety_name].present?
        plant_variety = PlantVariety.find_by!(plant_variety_name: attrs.delete(:plant_variety_name))
        attrs[:plant_variety_id] = plant_variety.id
      end

      if PlantLine.where(plant_line_name: attrs[:plant_line_name]).exists?
        rollback(2)
      else
        PlantLine.create!(attrs)
      end
    end
  end

  def create_plant_population
    attrs = {
      name: submission.content.step01.name,
      population_owned_by: submission.content.step01.owned_by,
      date_entered: Date.today,
      entered_by_whom: submission.user.full_name,
      user: submission.user
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
    attrs.delete(:owned_by)

    if PlantPopulation.where(name: attrs[:name]).exists?
      rollback(0)
    else
      @plant_population = PlantPopulation.create!(attrs)
    end
  end

  def create_plant_population_lists
    @plant_population_lists = submission.content.step03.plant_line_list.select(&:present?).map do |id_or_name|
      plant_line = PlantLine.where_id_or_name(id_or_name).first!
      PlantPopulationList.create!(
        plant_population: plant_population,
        plant_line: plant_line,
        date_entered: Date.today,
        data_provenance: submission.content.step04.data_provenance,
        entered_by_whom: submission.user.login
      )
    end
  end

  def update_submission
    submission.update_attributes!(
      finalized: true,
      submitted_object_id: @plant_population.id
    )
  end

  def rollback(to_step)
    submission.errors.add(:step, to_step)
    raise ActiveRecord::Rollback
  end
end
