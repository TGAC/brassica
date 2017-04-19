window.AnalysisRefresher = class AnalysisRefresher extends Component
  constructor: (el, timeout = 2000) ->
    super
    @timeout = timeout
    @status = @$el.data("analysis-status")

  init: =>
    return unless @$el.length > 0

    this.checkStatus() if @status == "idle" || @status == "running"

  checkStatus: =>
    ajax = =>
      $.ajax
        method: 'get'
        dataType: "json"
        url: window.location.href,
        cache: false
        success: (analysis) =>
          this.processResponse(analysis.status)

    setTimeout(ajax, @timeout)

  processResponse: (newStatus) =>
    reload_link = "<a href='#{window.location.href}'>Reload page.</a>"

    if newStatus == "success"
      Flash.notice("Your analysis is completed. #{reload_link}")
    else if newStatus == "failure"
      Flash.notice("Your analysis failed. #{reload_link}")
    else
      this.checkStatus()
