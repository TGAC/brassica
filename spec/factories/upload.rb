include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :upload, class: Submission::Upload do
    upload_type 'trait_scores'
    file { fixture_file_upload(Rails.root.join(*%w(spec fixtures files score_upload.txt)), 'text/plain') }
    association :submission, submission_type: :trial

    trait :trait_scores do
    end

    trait :plant_trial_layout do
      upload_type 'plant_trial_layout'
      file { fixture_file_upload(Rails.root.join(*%w(spec fixtures files plant-trial-layout-example.jpg)), 'image/jpeg') }
      association :submission, submission_type: :trial
    end
  end
end
