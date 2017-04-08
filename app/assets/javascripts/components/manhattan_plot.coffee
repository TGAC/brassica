window.ManhattanPlot = class ManhattanPlot extends Component
  init: =>
    return if @$el.length == 0

    data = @$el.data()

    @$plotEl = @$el.append("<div>").addClass("hidden")
    @chromosomes = data.chromosomes
    @traces = this.prepareTraces(data.traits)

    this.plot().then =>
      @$el.find('.loading').remove()
      @$plotEl.removeClass("hidden")

  prepareTraces: (traits) =>
    $.map(traits, (trace, trace_idx) ->
        name: trace[0]
        x: $.map(trace[1], (_, idx) -> idx)
        y: $.map(trace[1], (mut) -> mut[1])
        hoverinfo: "text"
        text: trace[2]
        mode: "markers"
        type: "scatter"
        marker:
          color: $.map(trace[1], (mut) -> (mut[2] * 11) % 7 ) # color depends on chromosome
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

  options: =>
    showLink: false
    displayLogo: false
    modeBarButtonsToRemove: ['lasso2d', 'select2d', 'autoScale2d']
