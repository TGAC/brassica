formatPlantLine = (plantLine) ->
  plantLine.text

plantLineSelectOptions = ->
  allowClear: true
  minimumInputLength: 2
  ajax:
    url: "/plant_lines"
    dataType: 'json'
    data: (params) ->
      search: params.term
      page: params.page
    processResults: (data, page) ->
      results: $.map(data.data, (row) -> { id: row[0], text: row[0] })
  escapeMarkup: (markup) -> markup
  templateResult: formatPlantLine
  templateSelection: formatPlantLine

defaultSelectOptions = ->
  allowClear: true

buttonTargets =
  'add-plant-line': '.new-plant-line'
  'select-existing-plant-line': '.existing-plant-line'
  'select-existing-taxonomy-term': '.existing-taxonomy-term'

buttonTargetSelectOptions =
  'add-plant-line': plantLineSelectOptions
  'select-existing-plant-line': plantLineSelectOptions
  'select-existing-taxonomy-term': defaultSelectOptions

markActiveButton = (button) ->
  $(button).parent().find('button').removeClass('active')
  $(button).addClass('active')

activateTargetFields = (button) ->
  target = buttonTargets[button.id]
  initialized = !$(target).hasClass('hidden')

  $('.new-plant-line, .existing-plant-line, .existing-taxonomy-term').not(target).hide()
  $(target).removeClass('hidden').show()

  unless initialized
    $(target).find('select').select2(buttonTargetSelectOptions[button.id]())

switchTarget = (button) ->
  markActiveButton(button)
  activateTargetFields(button)

$ ->
  $('.edit_submission .female-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .male-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .population-type').select2(defaultSelectOptions())

  $.each buttonTargets, (buttonId, target) ->
    $button = $('#' + buttonId)

    $button.on 'click', (event) ->
      event.preventDefault()
      switchTarget(event.target)

    if $(buttonTargets[buttonId]).hasClass('selected')
      markActiveButton($button[0])
      activateTargetFields($button[0])

