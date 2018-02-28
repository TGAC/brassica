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
      result_files = traits.map { |trait| "GAPIT..#{trait}.GWAS.Results.csv" }
      aux_result_files = Dir.
        glob(File.join(runner.results_dir, "*")).
        reject { |filename| File.directory?(filename) }.
        map { |filename| File.basename(filename) } - result_files

      result_files.each { |filename| runner.store_result(filename, data_type: :gwas_results) }
      aux_result_files.each { |filename| runner.store_result(filename, data_type: :gwas_aux_results) }

      analysis.meta["traits_results"] = Hash[traits.zip(result_files)]
      analysis.save!
    end

    def traits
      return @traits if defined?(@traits)

      File.open(phenotype_data_file.file.path, "r") do |file|
        @traits = Analysis::PhenotypeCsvParser.new.call(file).trait_ids
      end

      @traits
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
