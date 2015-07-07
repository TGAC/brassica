include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :upload, class: Submission::Upload do
    upload_type 'trait_scores'
    file { fixture_file_upload(Rails.root.join('spec', 'support', 'score_upload.txt'), 'text/plain') }
    association :submission, submission_type: :trial
  end
end
