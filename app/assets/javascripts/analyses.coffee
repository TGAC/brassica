$ ->
  new GwasAnalysis('.new-gwas-analysis').init()
  new ManhattanPlot('#gwas-manhattan-plot').init()
  new AnalysisRefresher('.show-analysis').init()
  new AnalysisListRefresher('.analyses').init()

  data_table = $('#analysis_results table').DataTable(
    columnDefs: [
      { type: "num", targets: 3 }
    ]
  )

  # NOTE: No idea why, but it does not work if included in data table
  # definition above. Perhaps that's how it works with prepopulated tables?
  data_table.order([3, 'desc']).draw()
