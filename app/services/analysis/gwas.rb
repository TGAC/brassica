class Analysis
  class Gwas
    def initialize(analysis, runner: nil)
      @analysis = analysis
      @runner = runner
    end

    def call
      prepare_csv_data_files
      runner.call(job_command) do
        store_results
      end
    end

    private

    attr_reader :analysis

    def prepare_csv_data_files
      geno_csv_data_file = genotype_data_file(:csv)

      if !geno_csv_data_file
        # NOTE: no need to normalize as coversion already outputs correct files
        convert_genotype_vcf_to_csv
      elsif geno_csv_data_file.uploaded?
        mutations_to_remove = find_mutations_to_remove(geno_csv_data_file)
        normalize_csv(geno_csv_data_file, remove_columns: mutations_to_remove)
        normalize_csv(map_data_file, remove_rows: mutations_to_remove) if map_data_file
      end

      normalize_csv(phenotype_data_file)
    end

    def convert_genotype_vcf_to_csv
      vcf_data_file = genotype_data_file(:vcf)

      genotype_csv, map_csv = Analysis::Gwas::GenotypeVcfToCsvConverter.new.call(vcf_data_file.file.path)

      analysis.data_files.create!(
        role: :input,
        origin: :generated,
        data_type: :gwas_genotype,
        file: genotype_csv,
        file_content_type: "text/csv",
        owner: analysis.owner
      )

      analysis.data_files.create!(
        role: :input,
        origin: :generated,
        data_type: :gwas_map,
        file: map_csv,
        file_content_type: "text/csv",
        owner: analysis.owner
      )
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

      values_by_mutation.map { |mutation, values| mutation if (values - ["NA"]).size < 2 }.compact - ["ID"]
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

      # TODO: store normalized files as separate ones with origin == "generated"
      Tempfile.open([File.basename(data_file.file.path, ".csv") + "-normalized", ".csv"]) do |file|
        file << normalized_csv
        file.flush
        file.rewind

        data_file.update!(file: file)
      end
    end

    def runner
      @runner ||= Analysis::ShellRunner.new(analysis)
    end

    def store_results
      selected_traits.each do |trait|
        runner.store_result("SNPAssociation-Full-#{trait}.csv", data_type: :gwas_results)
      end
    end

    def selected_traits
      @selected_traits ||= analysis.args["phenos"]

      unless @selected_traits.present?
        File.open(phenotype_data_file.file.path, "r") do |file|
          result = Analysis::Gwas::PhenotypeCsvParser.new.call(file)
          @selected_traits = result.trait_ids
        end
      end

      @selected_traits
    end

    def mixed_effect_traits
      @mixed_effect_traits ||= analysis.args["cov"]
    end

    def job_command
      args = [
        "--gFile", genotype_data_file(:csv).file.path,
        "--pFile", phenotype_data_file.file.path,
        "--outDir", runner.results_dir,
        "--noPlots"
      ]

      args += ["--phenos", selected_traits].flatten
      args += ["--cov", mixed_effect_traits].flatten if mixed_effect_traits.present?

      args = args.map { |part| Shellwords.escape(part) }

      ([gwas_script] + args).join(" ")
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

    def gwas_script
      Rails.application.config_for(:analyses).fetch("gwas")
    end
  end
end
