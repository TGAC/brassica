window.ManhattanPlot = class ManhattanPlot extends Component
  init: =>
    return if @$el.length == 0

    data = @$el.data()

    @$plotEl = @$el.append("<div>").addClass("hidden")
    @chromosomes = data.chromosomes
    @cutoff = data.cutoff
    @traces = this.prepareTraces(data.traits)

    this.plot().then =>
      @$el.find('.loading').remove()
      @$plotEl.removeClass("hidden")

      if @cutoff > 0
        @$plotEl[0].layout.shapes.push this.makeLine({ yref: 'y', y0: @cutoff, y1: @cutoff, x1: 1 }, { dash: 'dot' })

        update =
          'yaxis.range[0]': @cutoff - 1

        Plotly.relayout(@$plotEl[0], update)

  prepareTraces: (traits) =>
    chromosomeNames = $.map(@chromosomes, (c) -> c[0])

    $.map(traits, (trace, trace_idx) ->
        name: trace[0]
        x: $.map(trace[1], (_, idx) -> idx)
        y: $.map(trace[1], (mut) -> mut[1])
        hoverinfo: "text"
        text: trace[2]
        mode: "markers"
        type: "scatter"
        marker:
          color: $.map(trace[1], (mut) -> (chromosomeNames.indexOf(mut[2]) * 11) % 7 ) # color depends on chromosome
          symbol: trace_idx % 44 # symbol depends on trait
          opacity: 0.6
          colorscale: "Portland"
    )

  plot: =>
    Plotly.plot(
      @$plotEl[0],
      @traces,
      this.layout(),
      this.options()
    )

  layout: =>
    hovermode: 'closest'
    height: 600

    xaxis:
      title: 'Chromosome'
      tickvals: $.map(@chromosomes, (c) -> c[1] + (c[2] - c[1]) / 2)
      ticktext: $.map(@chromosomes, (c) -> c[0])
      ticks: "outside"
      showgrid: false

    yaxis:
      title: '-log10(p-value)'
      rangemode: "tozero"

    shapes: []

  options: =>
    showLink: false
    displayLogo: false
    modeBarButtonsToRemove: ['lasso2d', 'select2d', 'autoScale2d']

  makeLine: (overrides = {}, styleOverrides = {}) =>
    defaults = {
      type: 'line'
      xref: 'paper'
      yref: 'paper'
      x0: 0
      x1: 0
      y0: 0
      y1: 0
      opacity: 0.5
      line: $.extend({ width: 1 }, styleOverrides)
    }

    $.extend(defaults, overrides)
