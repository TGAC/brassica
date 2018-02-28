FactoryBot.define do
  factory :analysis do
    owner(factory: :user)
    sequence(:name) { |n| "Analysis #{n}" }

    trait :gwasser do
      analysis_type "gwasser"
      meta("phenos": %w(trait5 trait6 trait7))
    end

    trait :gwasser_with_results do
      analysis_type "gwasser"
      meta(
        "phenos": %w(trait5 trait6 trait7),
        "traits_results": {
          "trait5" => "SNPAssociation-Full-trait5.csv",
          "trait6" => "SNPAssociation-Full-trait6.csv",
          "trait7" => "SNPAssociation-Full-trait7.csv"
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
          "trait2": "GAPIT..trait2.GWAS.Results.csv",
          "trait3": "GAPIT..trait3.GWAS.Results.csv",
          "trait4": "GAPIT..trait4.GWAS.Results.csv",
          "trait5": "GAPIT..trait5.GWAS.Results.csv",
          "trait6": "GAPIT..trait6.GWAS.Results.csv",
          "trait7": "GAPIT..trait7.GWAS.Results.csv",
          "trait8": "GAPIT..trait8.GWAS.Results.csv",
          "trait9": "GAPIT..trait9.GWAS.Results.csv",
          "trait10": "GAPIT..trait10.GWAS.Results.csv"
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
