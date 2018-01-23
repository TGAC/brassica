class AnalysisJob < ApplicationJob
  def perform(analysis)
    case analysis.analysis_type
    when "gwasser"
      Analysis::Gwasser.new(analysis).call
    when "gapit"
      Analysis::Gapit.new(analysis).call
    end
  end
end
