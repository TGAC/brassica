$ ->
  new GwasAnalysis('.new-gwas-analysis').init()
  new ManhattanPlot('#gwas-manhattan-plot').init()

  $analysis = $('.show-analysis')
  status = $analysis.data("analysis-status")

  if status == "idle" || status == "running"
    checkStatus = (timeout = 5000) ->
      setTimeout ->
        $.ajax
          method: 'get'
          dataType: "json"
          url: window.location.href,
          cache: false
          success: (analysis) ->
            reload_link = "<a href='#{window.location.href}'>Reload page.</a>"

            if analysis.status == "success"
              Flash.notice("Your analysis is completed. #{reload_link}")
            else if analysis.status == "failure"
              Flash.notice("Your analysis failed. #{reload_link}")
            else
              checkStatus(timeout)

    checkStatus()
