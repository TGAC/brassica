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

plantLineListSelectOptions = ->
  $.extend({}, plantLineSelectOptions(), multiple: true)

plantLineGeneticStatusSelectOptions = ->
  multiple: true
  tags: true
  maximumSelectionLength: 1

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
  $('.edit_submission .plant-line-list').select2(plantLineListSelectOptions())

  $('.edit_submission .previous-line-name').select2(plantLineSelectOptions())
  $('.edit_submission .genetic-status').select2(plantLineGeneticStatusSelectOptions())

  $.each buttonTargets, (buttonId, target) ->
    $button = $('#' + buttonId)

    $button.on 'click', (event) ->
      event.preventDefault()
      switchTarget(event.target)

    if $(buttonTargets[buttonId]).hasClass('selected')
      markActiveButton($button[0])
      activateTargetFields($button[0])

  $('.add-plant-line-for-list').on 'click', (event) ->
    $select = $('.plant-line-list')
    $form = $('.new-plant-line-for-list')
    data =
      plant_line_name: $form.find('#plant_line_name').val()
      plant_line_comments: $form.find("#plant_line_comments").val()
      plant_line_data_provenance: $form.find("#plant_line_data_provenance").val()

    # FIXME validate plant line attributes before adding to plant line list select
    return if data.plant_line_name.toString().length == 0

    selectedValues = $select.val() || []

    $option = $('<option></option>').attr(value: data.plant_line_name).text(data.plant_line_name)
    $select.append($option)

    selectedValues.push(data.plant_line_name)
    $select.val(selectedValues)
    $select.trigger('change') # required to notify select2 about changes, see https://github.com/select2/select2/issues/3057

