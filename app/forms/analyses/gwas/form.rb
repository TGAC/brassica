module Analyses
  module Gwas
    class Form < BaseForm
      include Reform::Form::ActiveModel

      model :analysis

      property :analysis_type
      property :name
      property :genotype_data_file_id
      property :map_data_file_id
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

          unless geno.sample_ids.try(:sort) == pheno.sample_ids.try(:sort)
            errors.add(:base, :geno_pheno_samples_mismatch)
          end

          # TODO: check map file format and consistency with genotype data
        end
      end

      def genotype_data_file
        data_file = Analysis::DataFile.gwas_genotype.find_by(id: genotype_data_file_id)
        AnalysisDataFileDecorator.decorate(data_file) if data_file
      end

      def map_data_file
        data_file = Analysis::DataFile.gwas_map.find_by(id: map_data_file_id)
        AnalysisDataFileDecorator.decorate(data_file) if data_file
      end

      def phenotype_data_file
        data_file = Analysis::DataFile.gwas_phenotype.find_by(id: phenotype_data_file_id)
        AnalysisDataFileDecorator.decorate(data_file) if data_file
      end

      private

      def parse_genotype_data
        file = File.open(genotype_data_file.file.path, "r")
        genotype_data_parser.call(file)
      ensure
        file && file.close
      end

      def parse_phenotype_data
        file = File.open(phenotype_data_file.file.path, "r")
        phenotype_data_parser.call(file)
      ensure
        file && file.close
      end

      def genotype_data_parser
        case genotype_data_file.file_file_name
        when /.vcf\z/i
          Analysis::Gwas::GenotypeVcfParser.new
        else
          Analysis::Gwas::GenotypeCsvParser.new
        end
      end

      def phenotype_data_parser
        Analysis::Gwas::PhenotypeCsvParser.new
      end
    end
  end
end
