# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require jquery.dataTables
#= require dataTables.bootstrap
#= require_tree .

$ ->

  formatPlantLine = (plantLine) ->
    plantLine.text

  plantLineSelectOptions = ->
    allowClear: true
    minimumInputLength: 2
    ajax:
      url: "/plant_lines"
      dataType: 'json'
      data: (params) ->
        name: params.term
        page: params.page
      processResults: (data, page) ->
        results: data
    escapeMarkup: (markup) -> markup
    templateResult: formatPlantLine
    templateSelection: formatPlantLine

  $('.edit_submission .plant-line').select2(plantLineSelectOptions())
  $('.edit_submission .female-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .male-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission').find('.population-type, .taxonomy-term').select2
    allowClear: true

