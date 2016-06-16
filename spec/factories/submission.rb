FactoryGirl.define do
  factory :submission do
    submission_type { %i(population trial).sample }
    user

    trait :population do
      submission_type :population
    end

    trait :trial do
      submission_type :trial
    end

    trait :finalized do
      after(:build) do |submission|
        def random_word
          Faker::Lorem.word + rand(10000).to_s
        end

        if submission.population?
          submission.content.update(:step01, name: random_word,
                                             description: Faker::Lorem.sentence,
                                             owned_by: Faker::Internet.email)
          submission.content.update(:step02, population_type: random_word,
                                             taxonomy_term: random_word)
          submission.content.update(:step03, female_parent_line: nil,
                                             male_parent_line: nil,
                                             plant_line_list: [])
          submission.content.update(:step04, comments: Faker::Lorem.sentence,
                                             visibility: submission.published? ? 'published' : 'private')

          submission.step = :step04

          FactoryGirl.create(:taxonomy_term, name: submission.content.step02.taxonomy_term)
          FactoryGirl.create(:population_type, population_type: submission.content.step02.population_type)
        elsif submission.trial?
          plant_population = FactoryGirl.create(:plant_population, user: submission.user)
          country = FactoryGirl.create(:country)
          trait_descriptor = FactoryGirl.create(:trait_descriptor)

          submission.content.update(:step01, plant_trial_name: random_word,
                                             project_descriptor: random_word,
                                             plant_population_id: plant_population.id,
                                             trial_year: 1999,
                                             place_name: random_word,
                                             country_id: country.id)
          submission.content.update(:step02, trait_descriptor_list: [trait_descriptor.id.to_s])
          submission.content.update(:step06, comments: Faker::Lorem.sentence,
                                             visibility: submission.published? ? 'published' : 'private')

          submission.step = :step06
        else
          raise "Factory does not support finalized #{submission.submission_type} submissions"
        end

        submission.finalize
      end
    end

    factory :finalized_submission, traits: [:finalized]
  end

end
