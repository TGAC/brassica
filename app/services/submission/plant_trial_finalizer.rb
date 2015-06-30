class Submission::PlantTrialFinalizer

  attr_reader :new_trait_descriptors, :plant_trial

  def initialize(submission)
    raise ArgumentError, "Submission already finalized" if submission.finalized?

    self.submission = submission
  end

  def call
    ActiveRecord::Base.transaction do
      create_new_trait_descriptors
      # FIXME TODO Solve the problem of assigning existing TraitDescriptors while their names are not unique!
      #            This probably requires saving their DB ids as well
      # FIXME TODO create_plant_scoring_units
      # FIXME TODO create_plant_scores
      create_plant_trial
      update_submission
    end
    submission.finalized?
  end

  private

  attr_accessor :submission

  def create_new_trait_descriptors
    @new_trait_descriptors = (submission.content.step03.new_trait_descriptors || []).map do |attrs|
      attrs = attrs.with_indifferent_access
      attrs = attrs.merge(
        entered_by_whom: submission.user.full_name,
        date_entered: Date.today,
        user: submission.user
      )

      TraitDescriptor.create!(attrs)
    end
  end

  def create_plant_trial
    attrs = {
      plant_trial_name: submission.content.step01.plant_trial_name,
      project_descriptor: submission.content.step01.project_descriptor,
      date_entered: Date.today,
      entered_by_whom: submission.user.full_name,
      user: submission.user
    }

    # TODO FIXME Assign chosen PlantPopulation
    # if plant_population = PlantPopulation.find_by(name: submission.content.step01.name)
    #   attrs.merge!(name: plant_population)
    # end

    attrs.merge!(submission.content.step04.to_h)

    if PlantTrial.where(plant_trial_name: attrs[:plant_trial_name]).exists?
      rollback(0)
    else
      @plant_trial = PlantTrial.create!(attrs)
    end
  end

  def update_submission
    submission.update_attributes!(
      finalized: true,
      submitted_object_id: @plant_trial.id
    )
  end

  def rollback(to_step)
    submission.errors.add(:step, to_step)
    raise ActiveRecord::Rollback
  end
end
