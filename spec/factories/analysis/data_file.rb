FactoryGirl.define do
  factory :analysis_data_file, class: "Analysis::DataFile" do
    owner(factory: :user)

    trait :input do
      role "input"
    end

    trait :output do
      role "output"
    end

    trait :gwas_genotype_csv do
      role "input"
      data_type "gwas_genotype"
      file { fixture_file("gwas-genotypes.csv", "text/csv") }
    end

    trait :gwas_genotype_vcf do
      role "input"
      data_type "gwas_genotype"
      file { fixture_file("gwas-genotypes.vcf", "text/vcard") }
    end

    trait :gwas_phenotype do
      role "input"
      data_type "gwas_phenotype"
      file { fixture_file("gwas-phenotypes.csv", "text/csv") }
    end
  end
end

