FactoryBot.define do
  factory :analysis do
    owner(factory: :user)
    sequence(:name) { |n| "Analysis #{n}" }

    trait :gwasser do
      analysis_type "gwasser"
      meta("phenos": %w(trait_5 trait_6 trait_7))
    end

    trait :gwasser_with_results do
      analysis_type "gwasser"
      meta(
        "phenos": %w(trait_5 trait_6 trait_7),
        "traits_results": {
          "trait_5" => "SNPAssociation-Full-trait_5.csv",
          "trait_6" => "SNPAssociation-Full-trait_6.csv",
          "trait_7" => "SNPAssociation-Full-trait_7.csv"
        }
      )

      after(:build) do |analysis|
        analysis.meta["phenos"].map do |trait_name|
          analysis.data_files <<
            build(:analysis_data_file, :gwasser_results, analysis: analysis, owner: analysis.owner,
                  file: fixture_file("gwasser/SNPAssociation-Full-#{trait_name}.csv", "text/csv"))

        end
      end
    end

    trait :gapit do
      analysis_type "gapit"
    end

    trait :gapit_with_results do
      analysis_type "gapit"
      meta(
        "traits_results": {
          "trait_2" => "GAPIT..trait_2.GWAS.Results.csv",
          "trait_3" => "GAPIT..trait_3.GWAS.Results.csv",
          "trait_4" => "GAPIT..trait_4.GWAS.Results.csv",
          "trait_5" => "GAPIT..trait_5.GWAS.Results.csv",
          "trait_6" => "GAPIT..trait_6.GWAS.Results.csv",
          "trait_7" => "GAPIT..trait_7.GWAS.Results.csv",
          "trait_8" => "GAPIT..trait_8.GWAS.Results.csv",
          "trait_9" => "GAPIT..trait_9.GWAS.Results.csv",
          "trait_10" => "GAPIT..trait_10.GWAS.Results.csv"
        }
      )

      after(:build) do |analysis|
        analysis.meta["traits_results"].map do |trait_name, filename|
          analysis.data_files <<
            build(:analysis_data_file, :gapit_results, analysis: analysis, owner: analysis.owner,
                  file: fixture_file("gapit/#{filename}", "text/csv"))

        end
      end
    end
  end
end
