class GwasAnalysisDecorator < Draper::Decorator
  delegate_all

  def removed_traits
    @removed_traits ||= meta['removed_traits']
  end

  def removed_mutations
    @removed_mutations ||= meta['removed_mutations']
  end
end
