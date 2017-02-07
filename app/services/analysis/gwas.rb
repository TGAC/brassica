class Analysis::Gwas
  def initialize(analysis)
    @analysis = analysis
  end

  def call
    runner.call(job_command) do
      store_results
    end
  end

  private

  attr_reader :analysis

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
  end

  def mixed_effect_traits
    @mixed_effect_traits ||= analysis.args["cov"]
  end

  def job_command
    parts = [
      ENV.fetch("GWAS_SCRIPT"),
      "--gFile", analysis.data_files.gwas_genotype.first.file.path,
      "--pFile", analysis.data_files.gwas_phenotype.first.file.path,
      "--outDir", runner.results_dir,
      "--noPlots"
    ]

    parts += ["--phenos", selected_traits].flatten
    parts += ["--cov", mixed_effect_traits].flatten if mixed_effect_traits.present?

    parts.map { |part| Shellwords.escape(part) }.join(" ")
  end
end
