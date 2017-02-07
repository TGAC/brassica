FactoryGirl.define do
  factory :analysis do
    owner(factory: :user)
    sequence(:name) { |n| "Analysis #{n}" }

    trait :gwas do
      analysis_type "gwas"
      args(
        "phenos": %w(trait5 trait6 trait7),
        "cov": %w()
      )

      after(:build) do |analysis, _evaluator|
        analysis.data_files.build(
          role: :input,
          data_type: :gwas_genotype,
          file: fixture_file_upload("files/gwas-genotypes.csv", "text/csv")
        )

        analysis.data_files.build(
          role: :input,
          data_type: :gwas_phenotype,
          file: fixture_file_upload("files/gwas-phenotypes.csv", "text/csv")
        )

        analysis.data_files.gwas_map.build(
          role: :input,
          data_type: :gwas_map,
          file: fixture_file_upload("files/gwas-map.csv", "text/csv")
        )
      end
    end
  end
end
