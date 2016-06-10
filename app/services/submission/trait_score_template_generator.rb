class Submission::TraitScoreTemplateGenerator

  def initialize(submission)
    raise ArgumentError, "Required plant trial submission" unless submission.trial?
    @submission = submission
  end

  def call
    traits = PlantTrialSubmissionDecorator.decorate(@submission).sorted_trait_names

    pl_pv_name = if @submission.content.step03.lines_or_varieties == 'plant_varieties'
                   'variety'
                 else
                   'line'
                 end

    design_factor_names = @submission.content.step03.design_factor_names || []
    design_factors = {
        'A' => design_factor_names.map{ 1 },
        'B' => design_factor_names.map{ 1 }
    }
    design_factors['B'][-1] = 2 if design_factors['B'].present?

    technical_replicate_numbers = @submission.content.step03.technical_replicate_numbers || {}
    traits = traits.map do |trait|
      if technical_replicate_numbers[trait] && technical_replicate_numbers[trait].to_i > 1
        reps_count = [technical_replicate_numbers[trait].to_i, 2].max
        reps_count.times.map { |rep| "#{trait}_rep#{rep + 1}" }
      else
        trait
      end
    end.flatten

    CSV.generate(headers: true) do |csv|
      csv << ['Plant scoring unit name'] + design_factor_names + ['Plant accession', 'Originating organisation', "Plant #{pl_pv_name}"] + traits

      ['A','B'].each do |sample|
        sample_values = traits.map.with_index do |trait,i|
          if technical_replicate_numbers[trait] && technical_replicate_numbers[trait].to_i > 1
            reps_count = [technical_replicate_numbers[trait].to_i, 2].max
            reps_count.times.map { |rep| "sample_#{sample}_rep#{rep + 1}_value_for_#{trait}__replace_it" }
          else
            "sample_#{sample}_value_for_#{trait}__replace_it"
          end
        end
        csv << ["Sample scoring unit #{sample} name - replace it"] +
            design_factors[sample] +
            ['Accession identifier - replace it',
             'Organisation name or acronym - replace it',
             "Plant #{pl_pv_name} name - replace it"] +
            sample_values
      end
    end
  end
end
