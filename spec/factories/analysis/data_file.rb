FactoryBot.define do
  factory :analysis_data_file, class: "Analysis::DataFile" do
    owner(factory: :user)

    trait :input do
      role "input"
    end

    trait :output do
      role "output"
    end

    trait :std_out do
      role "output"
      data_type "std_out"
      file { fixture_file("empty.txt", "text/plain") }
    end

    trait :std_err do
      role "output"
      data_type "std_err"
      file { fixture_file("empty.txt", "text/plain") }
    end

    trait :gwas_genotype_csv do
      role "input"
      data_type "gwas_genotype"
      file { fixture_file("gwas-genotypes.csv", "text/csv") }
    end

    trait :gwas_genotype_csv_with_no_relevant_mutations do
      role "input"
      data_type "gwas_genotype"
      file { fixture_file("gwas-genotypes-no-relevant-mutations.csv", "text/csv") }
    end

    trait :gwas_genotype_vcf do
      role "input"
      data_type "gwas_genotype"
      file { fixture_file("gwas-genotypes.vcf", "text/vcard") }
    end

    trait :gwas_genotype_vcf_with_no_relevant_mutations do
      role "input"
      data_type "gwas_genotype"
      file { fixture_file("gwas-genotypes-no-relevant-mutations.vcf", "text/vcard") }
    end

    trait :gwas_map do
      role "input"
      data_type "gwas_map"
      file { fixture_file("gwas-map.csv", "text/csv") }
    end

    trait :gwas_phenotype do
      role "input"
      data_type "gwas_phenotype"
      file { fixture_file("gwas-phenotypes.csv", "text/csv") }
    end

    trait :gwas_phenotype_with_no_relevant_traits do
      role "input"
      data_type "gwas_phenotype"
      file { fixture_file("gwas-phenotypes-no-relevant-traits.csv", "text/csv") }
    end

    trait :gwas_results do
      role "output"
      data_type "gwas_results"
      file { fixture_file("gwas-results.csv", "text/csv") }
    end
  end
end

