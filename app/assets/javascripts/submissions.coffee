formatPlantLine = (plantLine) ->
  plantLine.text

plantLineSelectOptions = ->
  allowClear: true
  minimumInputLength: 2
  ajax:
    url: "/plant_lines"
    dataType: 'json'
    data: (params) ->
      search:
        plant_line_name: params.term
      page: params.page
    processResults: (data, page) ->
      results: $.map(data.data, (row) -> { id: row[0], text: row[0] })
  escapeMarkup: (markup) -> markup
  templateResult: formatPlantLine
  templateSelection: formatPlantLine

plantLineListSelectOptions = ->
  $.extend({}, plantLineSelectOptions(), multiple: true)

plantLineGeneticStatusSelectOptions = ->
  allowClear: true

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

  # add all PL attributes to DOM so it can be sent with form
  $form = $('.edit_submission')
  $container = $('<div></div').attr(id: newPlantLineForListContainerId(data.plant_line_name))
  $container.appendTo($form)

  $.each(data, (attr, val) ->
    $input = $("<input type='hidden' name='submission[content][new_plant_lines][][" + attr + "]' />")
    $input.val(val)
    $input.appendTo($container)
  )

newPlantLineForListContainerId = (plant_line_name) ->
  'new-plant-line-' + plant_line_name.split(/\s+/).join('-').toLowerCase()

$ ->
  $('.edit_submission .female-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .male-parent-line').select2(plantLineSelectOptions())
  $('.edit_submission .population-type').select2(defaultSelectOptions())
  $('.edit_submission .plant-line-list').select2(plantLineListSelectOptions())

  $('.edit_submission .plant-line-list').on 'select2:unselect', (event) ->
    plant_line_name = event.params.data.id
    $("##{newPlantLineForListContainerId(plant_line_name)}").remove()

  $('button.new-plant-line-for-list').on 'click', (event) ->
    $(event.target).hide()
    $('div.new-plant-line-for-list').removeClass('hidden').show()

    $('.edit_submission .previous-line-name').select2(plantLineSelectOptions())
    $('.edit_submission .previous-line-name-wrapper').inputOrSelect()
    $('.edit_submission .genetic-status').select2(plantLineGeneticStatusSelectOptions())
    $('.edit_submission .genetic-status-wrapper').inputOrSelect()
    $('.edit_submission .new-plant-line-for-list input[type=text]').on 'keydown', (event) ->
      if event.keyCode == 13 # Enter key
        event.preventDefault() # Prevent form submission

  $('.add-new-plant-line-for-list').on 'click', (event) ->
    $form = $('.new-plant-line-for-list')

    [data, errors] = Errors.validate($form)

    if errors.length > 0
      Errors.hideAll()
      Errors.showAll(errors)
    else
      Errors.hideAll()

      appendToSelectedPlantLineLists(data)

      $('div.new-plant-line-for-list').hide()
      $('button.new-plant-line-for-list').show()

  $('.cancel-new-plant-line-for-list').on 'click', (event) ->
    $('div.new-plant-line-for-list').hide()
    $('button.new-plant-line-for-list').show()

