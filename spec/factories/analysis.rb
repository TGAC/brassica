FactoryBot.define do
  factory :analysis do
    owner(factory: :user)
    sequence(:name) { |n| "Analysis #{n}" }

    trait :gwasser do
      analysis_type "gwasser"
      meta(
        "phenos": %w(trait5 trait6 trait7),
        "cov": %w()
      )
    end
  end
end
