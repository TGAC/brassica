FactoryGirl.define do
  factory :analysis do
    owner(factory: :user)
    sequence(:name) { |n| "Analysis #{n}" }

    trait :gwas do
      analysis_type "gwas"
      meta(
        "phenos": %w(trait5 trait6 trait7),
        "cov": %w()
      )
    end
  end
end
