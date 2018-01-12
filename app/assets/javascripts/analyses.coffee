$ ->
  new GwasserAnalysis('.new-gwasser-analysis').init()
  new ManhattanPlot('#gwas-manhattan-plot').init()
  new AnalysisRefresher('.show-analysis').init()
  new AnalysisListRefresher('.analyses').init()

  data_table = $('#analysis_results.with-map table').DataTable(
    ajax:
      url: $(this).data("url")
      dataSrc: 'results'
    columns: [
      { data: 0 }
      { data: 2 }
      { data: 3 }
      { data: 1 }
      { data: 4 }
    ]
    columnDefs: [
      { type: "num", targets: 3 }
    ]
    order: [[3, 'desc']]
  )

  data_table = $('#analysis_results.no-map table').DataTable(
    ajax:
      url: $(this).data("url")
      dataSrc: 'results'
    columns: [
      { data: 0 }
      { data: 1 }
      { data: 2 }
    ]
    order: [[1, 'desc']]
  )
