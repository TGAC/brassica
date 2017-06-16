class Analysis
  class Gwas
    class Setup
      attr_accessor :failure_reason

      def initialize(analysis)
        @analysis = analysis
      end

      # TODO: make nicer names for generated / normalized data files
      # TODO: do not generate normalized files if it is not necessary
      def call
        geno_csv_data_file = genotype_data_file(:csv)

        if !geno_csv_data_file
          # NOTE: no need to normalize as conversion already outputs correct files
          # TODO: check if there are any mutations left
          convert_genotype_vcf_to_csv

        elsif geno_csv_data_file.uploaded?
          mutations_to_remove = find_columns_to_remove(geno_csv_data_file)

          @analysis.meta['removed_mutations'] = mutations_to_remove
          @analysis.save!

          geno_status = normalize_csv(geno_csv_data_file, remove_columns: mutations_to_remove)

          if geno_status != :ok
            self.failure_reason =
              case geno_status
              when :all_but_one_columns_removed
                :all_mutations_removed
              else
                :geno_csv_invalid
              end

            return
          end

          normalize_csv(map_data_file, remove_rows: mutations_to_remove) if map_data_file
        end

        if plant_trial_based?
          prepare_plant_trial_phenotype_csv_data_file
        else
          traits_to_remove = find_columns_to_remove(phenotype_data_file)

          @analysis.meta['removed_traits'] = traits_to_remove
          @analysis.save!

          pheno_status = normalize_csv(phenotype_data_file, remove_columns: traits_to_remove)

          if pheno_status != :ok
            self.failure_reason =
              case pheno_status
              when :all_but_one_columns_removed
                :all_traits_removed
              else
                :pheno_csv_invalid
              end

            return
          end
        end

        true
      end

      private

      attr_reader :analysis

      def convert_genotype_vcf_to_csv
        vcf_data_file = genotype_data_file(:vcf)

        genotype_csv, map_csv = Analysis::Gwas::GenotypeVcfToCsvConverter.new.call(vcf_data_file.file.path)

        create_csv_data_file(genotype_csv, data_type: :gwas_genotype)
        create_csv_data_file(map_csv, data_type: :gwas_map)
      end

      def prepare_plant_trial_phenotype_csv_data_file
        plant_trial = PlantTrial.visible(analysis.owner_id).find(analysis.meta.fetch("plant_trial_id"))
        phenotype_csv = Analysis::Gwas::PlantTrialPhenotypeCsvBuilder.new.build_csv(plant_trial)

        create_csv_data_file(phenotype_csv, data_type: :gwas_phenotype)
      end

      def plant_trial_based?
        analysis.meta["plant_trial_id"].present?
      end

      # Return headers of columns for which there is less than two distinct
      # values (NA does not count). Such columns cannot be passed as input
      # for GWASSER.
      def find_columns_to_remove(csv_data_file)
        values_by_col_name = Hash.new { |h, k| h[k] = Set.new }

        CSV.open(csv_data_file.file.path) do |csv|
          headers = csv.readline

          csv.each do |row|
            row.each.with_index do |val, col_idx|
              values_by_col_name[headers[col_idx]] << val
            end
          end
        end

        values_by_col_name.
          select { |col_name, values| (values - ["NA"]).size < 2 }.
          keys - ["ID"]
      end

      def normalize_csv(data_file, remove_columns: [], remove_rows: [])
        status, tmpfile = Analysis::Gwas::CsvNormalizer.new.
          call(data_file.file, remove_columns: remove_columns, remove_rows: remove_rows)

        if status == :ok
          create_csv_data_file(tmpfile, data_type: data_file.data_type)
        end

        status

      ensure
        tmpfile && tmpfile.close
      end

      def genotype_data_file(type = nil)
        scope = analysis.data_files.gwas_genotype
        scope = scope.send(type) if type
        scope.generated.first || scope.uploaded.first
      end

      def phenotype_data_file
        scope = analysis.data_files.gwas_phenotype
        scope.generated.first || scope.uploaded.first
      end

      def map_data_file
        scope = analysis.data_files.gwas_map
        scope.generated.first || scope.uploaded.first
      end

      def create_csv_data_file(file, data_type:)
        analysis.data_files.create!(
          role: :input,
          origin: :generated,
          data_type: data_type,
          file: file,
          file_content_type: "text/csv",
          owner: analysis.owner
        )
      end
    end
  end
end
