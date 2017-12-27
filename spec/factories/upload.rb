include ActionDispatch::TestProcess

FactoryBot.define do
  factory :upload, class: Submission::Upload do
    upload_type 'trait_scores'
    file { fixture_file("score_upload.txt", 'text/plain') }
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
      file { fixture_file("plant_lines_upload.txt", 'text/plain') }
      association :submission, submission_type: :population
    end
  end
end
