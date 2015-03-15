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

appendToSelectedPlantLineLists = (data) ->
  $select = $('.plant-line-list')
  selectedValues = $select.val() || []

  $option = $('<option></option>').attr(value: data.plant_line_name).text(data.plant_line_name)
  $select.append($option)

  selectedValues.push(data.plant_line_name)
  $select.val(selectedValues)
  $select.trigger('change') # required to notify select2 about changes, see https://github.com/select2/select2/issues/3057

$ ->
  $('.edit_submission .female-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .male-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .population-type').select2(defaultSelectOptions())
  $('.edit_submission .plant-line-list').select2(plantLineListSelectOptions())

  $('.edit_submission .previous-line-name').select2(plantLineSelectOptions())
  $('.edit_submission .genetic-status').select2(plantLineGeneticStatusSelectOptions())

  $('.add-plant-line-for-list').on 'click', (event) ->
    $form = $('.new-plant-line-for-list')

    [data, errors] = Errors.validate($form)

    if errors.length > 0
      Errors.hideAll()
      Errors.showAll(errors)
    else
      Errors.hideAll()

      appendToSelectedPlantLineLists(data)

