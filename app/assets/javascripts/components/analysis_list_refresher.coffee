window.AnalysisListRefresher = class AnalysisListRefresher extends Component
  constructor: (el, timeout = 5000) ->
    super
    @timeout = timeout

  init: =>
    return unless @$el.length > 0

    this.$('[data-refresh=true]').each((_, row) =>
      this.refreshRow(row)
    )

  refreshRow: (row) =>
    ajax = =>
      $.ajax
        method: 'get'
        dataType: "html"
        url: $(row).data('url')
        cache: false
        success: (newRow) =>
          this.processResponse(row, newRow)

    setTimeout(ajax, @timeout)

  processResponse: (row, newRow) =>
    this.$("[data-id=#{$(row).data('id')}]").replaceWith(newRow)
    this.refreshRow(newRow) if $(newRow).data('refresh')

