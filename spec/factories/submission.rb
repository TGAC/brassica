FactoryBot.define do
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
                                             population_type: random_word,
                                             establishing_organisation: random_word,
                                             owned_by: Faker::Internet.email)
          submission.content.update(:step02, taxonomy_term: random_word,
                                             female_parent_line: nil,
                                             male_parent_line: nil)
          submission.content.update(:step04, plant_line_list: [])
          submission.content.update(:step05, comments: Faker::Lorem.sentence,
                                             visibility: submission.published? ? 'published' : 'private')

          submission.step = :step05

          FactoryBot.create(:taxonomy_term, name: submission.content.taxonomy_term)
          FactoryBot.create(:population_type, population_type: submission.content.population_type)
        elsif submission.trial?
          plant_population = FactoryBot.create(:plant_population, user: submission.user)
          country = FactoryBot.create(:country)
          trait_descriptor = FactoryBot.create(:trait_descriptor)

          submission.content.update(:step01, trait_descriptor_list: [trait_descriptor.id.to_s])
          submission.content.update(:step08, plant_trial_name: random_word,
                                             plant_trial_description: Faker::Lorem.sentence,
                                             project_descriptor: random_word,
                                             plant_population_id: plant_population.id,
                                             trial_year: 1999,
                                             institute_id: Faker::Company.name,
                                             place_name: random_word,
                                             country_id: country.id,
                                             comments: Faker::Lorem.sentence,
                                             visibility: submission.published? ? 'published' : 'private')

          submission.step = :step08
        else
          raise "Factory does not support finalized #{submission.submission_type} submissions"
        end

        submission.finalize
      end
    end

    factory :finalized_submission, traits: [:finalized]
  end

end
