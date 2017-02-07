module Analyses
  module Gwas
    class Form < BaseForm
      include Reform::Form::ActiveModel

      model :analysis

      property :analysis_type
      property :name
      property :genotype_data_file_id
      property :phenotype_data_file_id

      validates :name, presence: true
      validates :genotype_data_file, presence: true
      validates :phenotype_data_file, presence: true

      validate do
        if genotype_data_file && phenotype_data_file
          geno = parse_genotype_data
          pheno = parse_phenotype_data

          unless geno.valid?
            geno.errors.each { |error| errors.add(:genotype_data_file, error) }
          end

          unless pheno.valid?
            pheno.errors.each { |error| errors.add(:phenotype_data_file, error) }
          end

          unless geno.sample_ids.sort == pheno.sample_ids.sort
            errors.add(:base, :geno_pheno_samples_mismatch)
          end
        end
      end

      def genotype_data_file
        data_file = Analysis::DataFile.gwas_genotype.find_by(id: genotype_data_file_id)
        AnalysisDataFileDecorator.decorate(data_file) if data_file
      end

      def phenotype_data_file
        data_file = Analysis::DataFile.gwas_phenotype.find_by(id: phenotype_data_file_id)
        AnalysisDataFileDecorator.decorate(data_file) if data_file
      end

      private

      def parse_genotype_data
        Analyses::Gwas::GenotypeCsvParser.new.call(genotype_data_file)
      end

      def parse_phenotype_data
        Analyses::Gwas::PhenotypeCsvParser.new.call(phenotype_data_file)
      end
    end
  end
end
