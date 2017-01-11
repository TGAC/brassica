namespace :update_data do
  desc 'Move PT from step 2 to step 1 and move parent lines from step 3 to step 2'
  task move_population_submission_content: :environment do
    Submission.population.each do |submission|
      submission.content.update(:step01, population_type: submission.content.step02.population_type)
      submission.content.update(:step02, male_parent_line: submission.content.step03.male_parent_line)
      submission.content.update(:step02, female_parent_line: submission.content.step03.female_parent_line)
      submission.save!
    end
  end
end
