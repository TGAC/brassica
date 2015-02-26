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

  $('.edit_submission .female-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .male-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .population-type').select2(allowClear: true)

  markActiveButton = (button) ->
    $(button).parent().find('button').removeClass('active')
    $(button).addClass('active')

  activateNewPlantLineFields = ->
    $('.existing-plant-line, .existing-taxonomy-term').hide()
    $('.new-plant-line').removeClass('hidden').show()

  activateExistingPlantLineFields = ->
    initialized = !$('.existing-plant-line').hasClass('hidden')

    $('.new-plant-line, .existing-taxonomy-term').hide()
    $('.existing-plant-line').removeClass('hidden').show()

    unless initialized
      $('.edit_submission .plant-line').select2(plantLineSelectOptions())

  activateExistingTaxonomyTermFields = ->
    initialized = !$('.existing-taxonomy-term').hasClass('hidden')

    $('.new-plant-line, .existing-plant-line').hide()
    $('.existing-taxonomy-term').removeClass('hidden').show()

    unless initialized
      $('.edit_submission .taxonomy-term').select2(allowClear: true)

  if $('.edit_submission .existing-taxonomy-term').hasClass('selected')
    markActiveButton($('button.select-existing-taxonomy-term'))
    activateExistingTaxonomyTermFields()

  if $('.edit_submission .existing-plant-line').hasClass('selected')
    markActiveButton($('button.select-existing-plant-line'))
    activateExistingPlantLineFields()

  if $('.edit_submission .new-plant-line').hasClass('selected')
    markActiveButton($('button.add-plant-line'))
    activateNewPlantLineFields()

  $('.edit_submission .select-existing-taxonomy-term').on 'click', (event) ->
    event.preventDefault()
    markActiveButton(event.target)
    activateExistingTaxonomyTermFields()

  $('.edit_submission .select-existing-plant-line').on 'click', (event) ->
    event.preventDefault()
    markActiveButton(event.target)
    activateExistingPlantLineFields()

  $('.edit_submission .add-plant-line').on 'click', (event) ->
    event.preventDefault()
    markActiveButton(event.target)
    activateNewPlantLineFields()

