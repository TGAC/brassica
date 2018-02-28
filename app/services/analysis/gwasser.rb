class Analysis
  class Gwasser
    include Gwas::Helpers

    def initialize(analysis, runner: nil)
      @analysis = analysis
      @runner = runner
    end

    def call
      return unless perform_setup == :ok

      runner.call(job_command) do
        store_results
      end
    end

    private

    attr_reader :analysis

    def setup
      @setup ||= Analysis::Gwasser::Setup.new(analysis)
    end

    def runner
      @runner ||= Analysis::ShellRunner.new(analysis)
    end

    def perform_setup
      setup.call.tap do |status|
        runner.mark_as_failure(status) unless status == :ok
      end
    rescue => ex
      runner.mark_as_failure([:setup_error, ex.to_s])
    end

    def store_results
      result_files = selected_traits.map { |trait| "SNPAssociation-Full-#{trait}.csv" }
      result_files.each { |filename| runner.store_result(filename, data_type: :gwas_results) }

      analysis.meta["traits_results"] = Hash[selected_traits.zip(result_files)]
      analysis.save!
    end

    def selected_traits
      @selected_traits ||= analysis.meta["phenos"]

      unless @selected_traits.present?
        File.open(phenotype_data_file.file.path, "r") do |file|
          result = Analysis::PhenotypeCsvParser.new.call(file)
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

      ([gwasser_script] + args).join(" ")
    end

    def gwasser_script
      Rails.application.config_for(:analyses).fetch("gwasser")
    end
  end
end
