class Analysis
  class Gwas
    class Setup
      def initialize(analysis)
        @analysis = analysis
      end

      # TODO: make nicer names for generated / normalized data files
      # TODO: do not generate normalized files if it is not necessary
      def call
        geno_csv_data_file = genotype_data_file(:csv)

        if !geno_csv_data_file
          # NOTE: no need to normalize as conversion already outputs correct files
          convert_genotype_vcf_to_csv
        elsif geno_csv_data_file.uploaded?
          mutations_to_remove = find_mutations_to_remove(geno_csv_data_file)
          normalize_csv(geno_csv_data_file, remove_columns: mutations_to_remove)
          normalize_csv(map_data_file, remove_rows: mutations_to_remove) if map_data_file
        end

        if plant_trial_based?
          prepare_plant_trial_phenotype_csv_data_file
        else
          normalize_csv(phenotype_data_file)
        end
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

      def find_mutations_to_remove(geno_csv_data_file)
        values_by_mutation = Hash.new { |h, k| h[k] = Set.new }

        CSV.open(geno_csv_data_file.file.path) do |csv|
          headers = csv.readline

          csv.each do |row|
            row.each.with_index do |val, col_idx|
              values_by_mutation[headers[col_idx]] << val
            end
          end
        end

        values_by_mutation.
          select { |mutation, values| (values - ["NA"]).size < 2 }.
          keys - ["ID"]
      end

      def normalize_csv(data_file, remove_columns: [], remove_rows: [])
        normalized_csv = CSV.generate(force_quotes: true) do |csv|
          CSV.open(data_file.file.path, "r") do |existing_csv|
            headers = existing_csv.readline
            remove_col_idxes = remove_columns.map { |col| headers.index(col) }

            existing_csv.rewind
            existing_csv.each.with_index do |row, row_idx|
              next if remove_rows.include?(row[0])

              csv << row.map.with_index do |val, col_idx|
                next if remove_col_idxes.include?(col_idx)

                if row_idx == 0 || col_idx == 0
                  val.strip.gsub(/\W/, '_')
                else
                  val.strip
                end
              end.compact
            end
          end
        end

        Tempfile.open([File.basename(data_file.file.path, ".csv") + "-normalized", ".csv"]) do |file|
          file << normalized_csv
          file.flush
          file.rewind

          create_csv_data_file(file, data_type: data_file.data_type)
        end
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
