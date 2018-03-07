class Submission::TraitScoreTemplateGenerator

  def initialize(submission)
    raise ArgumentError, "Required plant trial submission" unless submission.trial?
    @submission = submission
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << ['Plant scoring unit name'] + design_factor_names + ['Plant accession', 'Originating organisation', "Year produced", "Plant #{line_or_variety}"] + traits

      ['A','B'].each do |sample|
        sample_values = traits.map.with_index do |trait, i|
          "Value of #{trait} scored for sample #{sample} - replace_it"
        end
        csv << ["Sample scoring unit #{sample} name - replace it"] +
            design_factors[sample] +
            ['Accession identifier - replace it',
             'Organisation name or acronym - replace it',
             'Year produced - replace it',
             "Plant #{line_or_variety} name - replace it"] +
            sample_values
      end
    end
  end

  private

  def line_or_variety
    @submission.content.lines_or_varieties == 'plant_varieties' ? 'variety' : 'line'
  end

  def trait_names
    PlantTrialSubmissionDecorator.decorate(@submission).sorted_trait_names
  end

  def traits
    technical_replicate_numbers = @submission.content.technical_replicate_numbers || {}
    trait_names.map.with_index do |trait_name, idx|
      if technical_replicate_numbers[idx] && technical_replicate_numbers[idx].to_i > 1
        reps_count = [technical_replicate_numbers[idx].to_i, 2].max
        reps_count.times.map { |rep| "#{trait_name} rep#{rep + 1}" }
      else
        trait_name
      end
    end.flatten
  end

  def design_factor_names
    @submission.content.design_factor_names || []
  end

  def design_factors
    design_factors = {
      'A' => design_factor_names.map { '1 - replace it' },
      'B' => design_factor_names.map { '1 - replace it' }
    }
    design_factors['B'][-1] = '2 - replace it' if design_factors['B'].present?
    design_factors
  end
end
