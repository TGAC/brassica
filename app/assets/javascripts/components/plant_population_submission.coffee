window.PlantPopulationSubmission = class PlantPopulationSubmission extends Submission
  defaultSelectOptions: { allowClear: true }
  plantLineSelectOptions: @makeAjaxSelectOptions('/plant_lines', 'plant_line_name', 'plant_line_name', 'common_name')
  plantLineListSelectOptions: @makeAjaxListSelectOptions('/plant_lines', 'id', 'plant_line_name', 'common_name')
  plantVarietySelectOptions: @makeAjaxSelectOptions('/plant_varieties', 'plant_variety_name', 'plant_variety_name', 'crop_type')

  init: =>
    return unless @$el.length >= 1

    @$('.taxonomy-term').select2(@defaultSelectOptions)
    @$('.male-parent-line, .female-parent-line').select2(@plantLineSelectOptions)
    @$('.population-type').select2(@defaultSelectOptions)
    @$('.plant-line-list').select2(@plantLineListSelectOptions)

    @bindPlantLinesUpload()
    @bindNewPlantLineControls()

    super()

  initDirtyTracker: =>
    super()

    $('input[type=submit][name=leave], input[type=submit][name=commit],
      button[type=submit][name=leave], button[type=submit][name=commit]').on 'click', (event) =>
      if @dirtyTracker.isChanged('new-plant-line')
        unless confirm("Discard new Plant line?")
          event.preventDefault()
          event.stopPropagation()

  bindNewPlantLineControls: =>
    @$('.plant-line-list').on 'select2:unselect', (event) =>
      @removeNewPlantLineFromList(event.params.data.id)

    @$('button.new-plant-line-for-list').on 'click', (event) =>
      $(event.target).hide()
      @initNewPlantLineForm()

    @$('.add-new-plant-line-for-list').on 'click', (event) =>
      @validateNewPlantLineForList((plantLineData) =>
        @appendToSelectedPlantLineLists(plantLineData)
        @dirtyTracker.resetContext("new-plant-line")
      )

    @$('.cancel-new-plant-line-for-list').on 'click', (event) =>
      @$('div.new-plant-line-for-list').hide()
      @$('button.new-plant-line-for-list').show()
      @dirtyTracker.resetContext("new-plant-line")

  initNewPlantLineForm: =>
    @$('div.new-plant-line-for-list').removeClass('hidden').show()

    @$('.previous-line-name').select2(@plantLineSelectOptions)
    @$('.previous-line-name-wrapper').comboField()
    @$('.genetic-status').select2(@defaultSelectOptions)
    @$('.genetic-status-wrapper').comboField()
    @$('.new-plant-line-for-list input[type=text]').on 'keydown', (event) =>
      if event.keyCode == 13 # Enter key
        event.preventDefault() # Prevent form submission

    @$('.plant-variety-name').select2(@plantVarietySelectOptions)

  newPlantLineForListContainerId: (plant_line_name) =>
    'new-plant-line-' + plant_line_name.split(/\s+/).join('-').toLowerCase()

  validateNewPlantLineForList: (onValidData) =>
    $form = @$('.new-plant-line-for-list')

    [data, errors] = Errors.validate($form)

    if errors.length > 0
      Errors.hideAll()
      Errors.showAll(errors)
    else
      Errors.hideAll()

      onValidData(data)

      @$('div.new-plant-line-for-list').hide()
      @$('button.new-plant-line-for-list').show()

  hasNewPlantLine: (data) =>
    fieldName = "submission[content][new_plant_lines][][plant_line_name]"
    $("[name='#{fieldName}'][value=#{data.plant_line_name}]").length > 0

  appendToSelectedPlantLineLists: (data) =>
    $select = @$('.plant-line-list')
    selectedValues = $select.val() || []

    $option = $('<option></option>').attr(value: data.plant_line_name).text(data.plant_line_name)
    $select.append($option)

    selectedValues.push(data.plant_line_name)
    $select.val(selectedValues)
    $select.trigger('change') # required to notify select2 about changes, see https://github.com/select2/select2/issues/3057

    # add all PL attributes to DOM so it can be sent with form
    $form = @$el.find('form')
    $container = $('<div></div').attr(id: @newPlantLineForListContainerId(data.plant_line_name))
    $container.appendTo($form)

    $.each(data, (attr, val) =>
      $input = $("<input type='hidden' name='submission[content][new_plant_lines][][" + attr + "]' />")
      $input.val(val)
      $input.appendTo($container)
    )

  removeNewPlantLineFromList: (plant_line_name) =>
    $("##{@newPlantLineForListContainerId(plant_line_name)}").remove()

    $select = @$('.plant-line-list')
    $option = $select.find("option[value=#{plant_line_name}]")
    $option.remove()

  bindPlantLinesUpload: =>
    @$('.plant-lines-upload').fileupload
      data_type: 'json'

      add: (event, data) =>
        @$('.fileinput-button').addClass('disabled')
        data.submit()

      done: (event, data) =>
        $(".errors").addClass('hidden').text("")

        @$('#submission_content_upload_id').val(data.result.id)

        @$('.fileinput').addClass('hidden')
        @$('.fileinput-button').removeClass('disabled')
        @$('.uploaded-plant-lines').removeClass('hidden')
        @$('.uploaded-plant-lines .file-name').text(data.result.file_file_name)
        @$('.uploaded-plant-lines .delete-plant-lines-upload').attr(href: data.result.delete_url)
        @$('.uploaded-plant-lines .parser-logs').removeClass('hidden')
        @$('.uploaded-plant-lines .parser-logs').text(data.result.logs.join('\n'))
        if data.result.errors.length > 0
          @$('.uploaded-plant-lines .parser-errors').removeClass('hidden')
          @$('.uploaded-plant-lines .parser-errors').text(data.result.errors.join('\n'))
        else
          @$('.uploaded-plant-lines .parser-errors').addClass('hidden')
          @$('.uploaded-plant-lines .parser-errors').text('')

          $.each(data.result.new_plant_lines, (_, newPlantLine) =>
            @appendToSelectedPlantLineLists(newPlantLine) unless @hasNewPlantLine(newPlantLine)
          )

      fail: (event, data) =>
        if data.jqXHR.status == 401
          window.location.reload()
        else if data.jqXHR.status == 422
          @$('.fileinput-button').removeClass('disabled')

          $errors = $(".errors").text("").removeClass('hidden').append("<ul></ul>")
          $.each(data.jqXHR.responseJSON.errors, (_, error) =>
            $li = $("<li></li>").text(error)
            $errors.find("ul").append($li)
          )

    @$('.delete-plant-lines-upload').on 'ajax:success', (data, status, xhr) =>
      @$('.fileinput').removeClass('hidden')
      @$('.uploaded-plant-lines').addClass('hidden')
