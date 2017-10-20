class AnalysisJob < JobBase
  def perform(analysis)
    case analysis.analysis_type
    when "gwas"
      Analysis::Gwas.new(analysis).call
    end
  end
end
