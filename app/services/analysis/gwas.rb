class Analysis
  class Gwas
    include Setup::Helpers

    def initialize(analysis, runner: nil)
      @analysis = analysis
      @runner = runner
    end

    def call
      status = setup.call

      unless status == :ok
        runner.mark_as_failure(status)
        return
      end

      runner.call(job_command) do
        store_results
      end
    end

    private

    attr_reader :analysis

    def setup
      @setup ||= Analysis::Gwas::Setup.new(analysis)
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
      @selected_traits ||= analysis.meta["phenos"]

      unless @selected_traits.present?
        File.open(phenotype_data_file.file.path, "r") do |file|
          result = Analysis::Gwas::PhenotypeCsvParser.new.call(file)
          @selected_traits = result.trait_ids
        end
      end

      @selected_traits
    end

    def mixed_effect_traits
      @mixed_effect_traits ||= analysis.meta["cov"]
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

    def gwas_script
      Rails.application.config_for(:analyses).fetch("gwas")
    end
  end
end
