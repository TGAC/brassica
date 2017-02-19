class Analysis
  class Gwas
    def initialize(analysis, runner: nil)
      @analysis = analysis
      @runner = runner
    end

    def call
      prepare_csv_genotype_data_file
      runner.call(job_command) do
        store_results
      end
    end

    private

    attr_reader :analysis

    def prepare_csv_genotype_data_file
      return if csv_data_file = genotype_data_file(:csv)

      vcf_data_file = genotype_data_file

      csv = Analysis::Gwas::GenotypeVcfToCsvConverter.new.call(vcf_data_file.file.path)

      analysis.data_files.create!(
        role: :input,
        data_type: :gwas_genotype,
        file: csv,
        file_content_type: "text/csv",
        owner: analysis.owner
      )
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
      @selected_traits ||= analysis.args.fetch("phenos")

      unless @selected_traits.present?
        file = File.open(phenotype_data_file.file.path, "r")
        result = Analysis::Gwas::PhenotypeCsvParser.new.call(file)
        @selected_traits = result.trait_ids
      end

      @selected_traits

    ensure
      file && file.close
    end

    def mixed_effect_traits
      @mixed_effect_traits ||= analysis.args["cov"]
    end

    def job_command
      parts = [
        ENV.fetch("GWAS_SCRIPT"),
        "--gFile", genotype_data_file(:csv).file.path,
        "--pFile", phenotype_data_file.file.path,
        "--outDir", runner.results_dir,
        "--noPlots"
      ]

      parts += ["--phenos", selected_traits].flatten
      parts += ["--cov", mixed_effect_traits].flatten if mixed_effect_traits.present?

      parts.map { |part| Shellwords.escape(part) }.join(" ")
    end

    def genotype_data_file(type = nil)
      scope = analysis.data_files.gwas_genotype
      scope = scope.csv if type
      scope.first
    end

    def phenotype_data_file
      analysis.data_files.gwas_phenotype.first
    end
  end
end
