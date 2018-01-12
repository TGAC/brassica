class AnalysisJob < JobBase
  def perform(analysis)
    case analysis.analysis_type
    when "gwasser"
      Analysis::Gwasser.new(analysis).call
    end
  end
end
