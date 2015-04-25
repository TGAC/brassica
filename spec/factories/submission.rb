FactoryGirl.define do
  factory :submission do
    submission_type :population
    user

    trait :finalized do
      after(:build) do |submission|
        submission.content.update(:step01, name: Faker::Lorem.word,
                                           description: Faker::Lorem.sentence,
                                           owned_by: Faker::Internet.email)
        submission.content.update(:step02, population_type: Faker::Lorem.word,
                                           taxonomy_term: Faker::Lorem.word + rand(100).to_s)
        submission.content.update(:step03, female_parent_line: nil,
                                           male_parent_line: nil,
                                           plant_line_list: [])
        submission.content.update(:step04, comments: Faker::Lorem.sentence)

        FactoryGirl.create(:taxonomy_term, name: submission.content.step02.taxonomy_term)
        FactoryGirl.create(:population_type, population_type: submission.content.step02.population_type)

        submission.step = :step04
        submission.finalize
      end
    end

    factory :finalized_submission, traits: [:finalized]
  end
end
