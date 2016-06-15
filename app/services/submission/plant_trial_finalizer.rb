class Submission::PlantTrialFinalizer

  attr_reader :new_trait_descriptors, :plant_trial

  def initialize(submission)
    raise ArgumentError, "Submission already finalized" if submission.finalized?

    self.submission = submission
  end

  def call
    ActiveRecord::Base.transaction do
      create_plant_trial
      create_new_trait_descriptors
      create_scoring
      update_submission
    end
    submission.finalized?
  end

  private

  attr_accessor :submission

  def create_new_trait_descriptors
    @new_trait_descriptors = (submission.content.step02.new_trait_descriptors || []).map do |attrs|
      attrs = attrs.with_indifferent_access
      attrs = attrs.merge(common_data)
      if attrs[:trait].present?
        attrs[:trait] = Trait.find_by_name(attrs['trait'])
      end
      TraitDescriptor.create!(attrs)
    end
  end

  def find_or_create_plant_variety(plant_id)
    PlantVariety.find_or_create_by!(
      plant_variety_name: lines_or_varieties[plant_id]['relation_record_name']
    ) do |new_plant_variety|
      new_plant_variety.assign_attributes(common_data)
    end
  end

  def find_or_create_plant_accession(plant_id)
    PlantAccession.find_or_create_by!(
      plant_accession: accessions[plant_id]['plant_accession'],
      originating_organisation: accessions[plant_id]['originating_organisation']
    ) do |new_plant_accession|
      # If new accession, set PL or PV relation for that accession
      accession_relation = {}

      if lines_or_varieties[plant_id].blank?
        raise 'Required plant line or plant variety data not available after parsing.'

      elsif lines_or_varieties[plant_id]['relation_class_name'] == 'PlantVariety'
        accession_relation = { plant_variety: find_or_create_plant_variety(plant_id) }

      elsif lines_or_varieties[plant_id]['relation_class_name'] == 'PlantLine'
        plant_line = PlantLine.find_by(
            plant_line_name: lines_or_varieties[plant_id]['relation_record_name']
        )
        if plant_line
          accession_relation = { plant_line: plant_line }
        else
          #TODO Inform the user there is no PlantLine of a given name and that it should be submitted with another submission first
          rollback(2)
        end

      else
        raise "Incorrect value [#{lines_or_varieties[plant_id]['relation_class_name']}] user for relation name for a new accession."
      end

      new_plant_accession.assign_attributes(common_data.merge(accession_relation))
    end
  end

  def create_design_factor(plant_id)
    design_factor = nil
    factor_values = design_factors[plant_id]
    if design_factor_names.present? && factor_values.present?
      factor_attrs = {}
      factor_values.each_with_index do |factor_value, i|
        factor_attrs["design_factor_#{i+1}".to_sym] = if design_factor_names[i]
                                                        "#{design_factor_names[i]}_#{factor_value}"
                                                      else
                                                        nil
                                                      end
      end
      design_factor = DesignFactor.create!(
        common_data.except(:user, :published, :published_on).merge(
          design_unit_counter: factor_values.last
        ).merge(
          factor_attrs
        )
      )
    end
    design_factor
  end

  def create_scoring
    trait_mapping = submission.content.step04.trait_mapping
    trait_scores = submission.content.step04.trait_scores || {}
    replicate_numbers = submission.content.step04.replicate_numbers || {}

    @new_plant_scoring_units = trait_scores.map do |plant_id, scores|
      unless accessions[plant_id] && accessions[plant_id]['plant_accession'] && accessions[plant_id]['originating_organisation']
        raise 'Misformed parsed plant accession data.'
      end

      plant_accession = find_or_create_plant_accession(plant_id)

      design_factor = create_design_factor(plant_id)

      new_plant_scoring_unit = PlantScoringUnit.create!(
        common_data.merge(scoring_unit_name: plant_id,
                          plant_accession_id: plant_accession.id,
                          design_factor_id: design_factor.try(:id),
                          plant_trial_id: @plant_trial.id)
      )

      (scores || {}).
        select{ |_, value| value.present? }.
        map do |col_index, value|
          trait_descriptor = get_nth_trait_descriptor(trait_mapping[col_index])
          rollback(1) unless trait_descriptor

          trait_score_attributes = common_data.dup
          if replicate_numbers[col_index] && replicate_numbers[col_index] > 0
            trait_score_attributes.merge!(
              technical_replicate_number: replicate_numbers[col_index]
            )
          end

          TraitScore.create!(
            trait_score_attributes.merge(
              trait_descriptor: trait_descriptor,
              score_value: value,
              plant_scoring_unit_id: new_plant_scoring_unit.id
            )
          )
      end
      new_plant_scoring_unit
    end
  end

  def create_plant_trial
    attrs = submission.content.step01.to_h.merge(common_data)
    design_factor_names = submission.content.step04.design_factor_names || []

    if plant_population = PlantPopulation.find_by(id: submission.content.step01.plant_population_id)
      attrs.merge!(plant_population_id: plant_population.id)
    else
      submission.content.update(:step01, submission.content.step01.to_h.except('plant_population_id'))
      submission.save!
      rollback(0)
    end

    if layout_upload = Submission::Upload.find_by(id: submission.content.step05.layout_upload_id)
      attrs.merge!(layout: layout_upload.file)
    end

    attrs.merge!(submission.content.step06.to_h.except(:visibility))
    attrs.merge!(design_factors: describe_design_factors(design_factor_names))
    attrs.merge!(published: publish?)

    if PlantTrial.where(plant_trial_name: attrs[:plant_trial_name]).exists?
      rollback(0)
    else
      @plant_trial = PlantTrial.create!(attrs.except(:data_status))
    end
  end

  def update_submission
    submission.update_attributes!(
      finalized: true,
      published: publish?,
      submitted_object_id: @plant_trial.id
    )
  end

  def rollback(to_step)
    submission.errors.add(:step, to_step)
    raise ActiveRecord::Rollback
  end

  def publish?
    @publish ||= submission.content.step06.visibility.to_s == 'published'
  end

  def common_data
    {
      date_entered: Date.today,
      entered_by_whom: submission.user.full_name,
      user: submission.user,
      published: publish?,
      published_on: (Time.now if publish?)
    }
  end

  def get_nth_trait_descriptor(n)
    trait = submission.content.step02.trait_descriptor_list[n]
    if trait.to_i.to_s == trait.to_s
      TraitDescriptor.find_by(id: trait)
    else
      @new_trait_descriptors.detect{ |ntd| ntd.trait.name == trait }
    end
  end

  def describe_design_factors(design_factor_names)
    design_factor_names.compact.join(' / ')
  end

  def design_factors
    submission.content.step04.design_factors || {}
  end

  def design_factor_names
    submission.content.step04.design_factor_names || []
  end

  def accessions
    submission.content.step04.accessions
  end

  def lines_or_varieties
    submission.content.step04.lines_or_varieties || {}
  end
end
