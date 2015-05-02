renderStats = ->
  $(".pie-chart").easyPieChart
    barColor: "#72C02C"
    scaleColor: "#ccc"
    size: "160"

$ ->
  $(".section-statistics").one 'inview', (event, visible) ->
    if visible
      setTimeout (->
        renderStats()
      ), 500