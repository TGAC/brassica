class Analysis
  class Gapit
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
      @setup ||= Analysis::Gapit::Setup.new(analysis)
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
      selected_traits.each do |trait|
        runner.store_result("GAPIT..#{trait}.GWAS.Results.csv", data_type: :gwas_results)
      end
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

    def job_command
      args = [
        "--gapitDir", gapit_dir,
        "--outDir", runner.results_dir,
        "--Y", phenotype_data_file.file.path
      ]

      if genotype_data_file(:hapmap).present?
        args = args.push("--G",genotype_data_file(:hapmap).file.path)
      else
        args = args.push(
          "--GD", genotype_data_file(:csv).file.path,
          "--GM", map_data_file.file.path
        )
      end

      args = args.map { |part| Shellwords.escape(part) }

      script = Shellwords.escape(script)

      "#{([gapit_script] + args).join(" ")}"
    end

    def gapit_script
      Rails.application.config_for(:analyses).fetch("gapit")
    end

    def gapit_dir
      Rails.application.config_for(:analyses).fetch("gapit_dir")
    end
  end
end
