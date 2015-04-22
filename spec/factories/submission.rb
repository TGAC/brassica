FactoryGirl.define do
  factory :submission do
    submission_type :population
    user

    trait :finalized do
      finalized true
      submitted_object_id { create(:plant_population).id }
    end

    factory :finalized_submission, traits: [:finalized]
  end
end
