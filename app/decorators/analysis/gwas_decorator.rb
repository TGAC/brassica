class Analysis::GwasDecorator < Draper::Decorator
  delegate_all

  def failure_reason
    reason, msg = meta['failure_reason'] || :shell_job_error

    [h.t(".failure_reason.#{reason}"), msg].join(" ")
  end

  def map?
    data_files.gwas_map.present?
  end

  def removed_inputs?
    removed_traits.present? || removed_mutations.present? || removed_samples.present?
  end

  def removed_traits
    @removed_traits ||= meta['removed_traits'].try(:sort)
  end

  def removed_mutations
    @removed_mutations ||= meta['removed_mutations'].try(:sort)
  end

  def removed_samples
    @removed_samples ||= ((geno_samples + pheno_samples) - (geno_samples & pheno_samples)).sort
  end

  private

  def geno_samples
    meta['geno_samples'] || []
  end

  def pheno_samples
    meta['pheno_samples'] || []
  end
end
