include ActionDispatch::TestProcess

FactoryBot.define do
  factory :submission_upload, class: Submission::Upload do
    upload_type 'trait_scores'
    file { fixture_file("trait_scores.xls", 'application/vnd.ms-excel') }
    association :submission, submission_type: :trial

    trait :trait_scores do
    end

    trait :plant_trial_layout do
      upload_type 'plant_trial_layout'
      file { fixture_file("plant-trial-layout-example.jpg", 'image/jpeg') }
      association :submission, submission_type: :trial
    end

    trait :plant_lines do
      upload_type 'plant_lines'
      file { fixture_file("plant_lines.xls", 'application/vnd.ms-excel') }
      association :submission, submission_type: :population
    end

    trait :plant_trial_environment do
      upload_type 'plant_trial_environment'
      file { fixture_file("plant-trial-environment.xls", 'application/vnd.ms-excel') }
      association :submission, submission_type: :trial
    end

    trait :plant_trial_treatment do
      upload_type 'plant_trial_treatment'
      file { fixture_file("plant-trial-treatment.xls", 'application/vnd.ms-excel') }
      association :submission, submission_type: :trial
    end
  end
end
