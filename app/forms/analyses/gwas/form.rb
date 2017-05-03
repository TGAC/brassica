module Analyses
  module Gwas
    class Form < BaseForm
      include Reform::Form::ActiveModel

      model :analysis

      property :owner
      property :analysis_type
      property :name
      property :plant_trial_id
      property :genotype_data_file_id
      property :map_data_file_id
      property :phenotype_data_file_id

      validates :owner, :name, presence: true
      validates :genotype_data_file, presence: true
      validates :phenotype_data_file, presence: true, unless: :plant_trial_based?

      validate :check_data

      def save!
        save do |attrs|
          attrs = attrs.except(:genotype_data_file_id, :phenotype_data_file_id, :map_data_file_id, :plant_trial_id)
          attrs[:meta] = { plan_trial_id: plant_trial_id } if plant_trial_based?

          Analysis.transaction do
            analysis = Analysis.create!(attrs)
            analysis.data_files << genotype_data_file
            analysis.data_files << map_data_file if map_data_file
            analysis.data_files << phenotype_data_file unless plant_trial_based?

            AnalysisJob.new(analysis).enqueue
          end
        end
      end

      def plant_trial_based?
        plant_trial_id.present?
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

      def check_data
        geno = parse_data_file(genotype_data_file, genotype_data_parser)
        map = parse_data_file(map_data_file, map_data_parser)
        pheno = prepare_pheno_data

        if geno && !geno.valid?
          geno.errors.each { |error| errors.add(:genotype_data_file, error) }
        end

        if pheno && !pheno.valid?
          pheno.errors.each { |error| errors.add(:phenotype_data_file, error) }
        end

        if geno && pheno
          if geno.sample_ids.try(:sort) != pheno.sample_ids.try(:sort)
            errors.add(:base, :geno_pheno_samples_mismatch)
          end
        end

        if map_data_file
          unless map.valid?
            map.errors.each { |error| errors.add(:map_data_file, error) }
          end
        end

        if geno && map
          if map.mutation_ids.try(:sort) != geno.mutation_ids.try(:sort)
            errors.add(:base, :geno_map_mutations_mismatch)
          end
        end
      end

      def parse_data_file(data_file, parser)
        return unless data_file

        File.open(data_file.file.path, "r") { |file| parser.call(file) }
      end

      def prepare_pheno_data
        if plant_trial_based?
          build_plant_trial_pheno_data
        else
          parse_data_file(phenotype_data_file, phenotype_data_parser)
        end
      end

      def build_plant_trial_pheno_data
        Analysis::Gwas::PlantTrialPhenotypeBuilder.new.build(plant_trial)
      end

      def genotype_data_parser
        case genotype_data_file.try(:file_file_name)
        when /.vcf\z/i
          Analysis::Gwas::GenotypeVcfParser.new
        else
          Analysis::Gwas::GenotypeCsvParser.new
        end
      end

      def map_data_parser
        Analysis::Gwas::MapCsvParser.new
      end

      def phenotype_data_parser
        Analysis::Gwas::PhenotypeCsvParser.new
      end

      def plant_trial
        PlantTrial.visible(owner.id).find(plant_trial_id)
      end
    end
  end
end
