$ ->
  new GwasAnalysis('.new-gwas-analysis').init()
  new ManhattanPlot('#gwas-manhattan-plot').init()
  new AnalysisRefresher('.show-analysis').init()
  new AnalysisListRefresher('.analyses').init()

  data_table = $('#analysis_results table').DataTable(
    columnDefs: [
      { type: "num", targets: 3 }
    ]
    order: [[3, 'desc']]
  )
