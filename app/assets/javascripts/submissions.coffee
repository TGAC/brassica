class Submission
  @makeAjaxSelectOptions: (url, id_attr, text_attr, small_text_attr) =>
    text_attr ||= id_attr

    allowClear: true
    minimumInputLength: 2
    ajax:
      url: url
      dataType: 'json'
      data: (params) ->
        search = {}
        search[text_attr] = params.term

        search: search
        page: params.page
      processResults: (data, params) ->
        results: $.map(data.results, (row) -> { id: row[id_attr], text: row[text_attr], small_text: row[small_text_attr] })
        pagination:
          more: data.page * data.per_page < data.total_count
    escapeMarkup: (markup) -> markup
    templateResult: (item) ->
      result = item.text
      result += "<br/><small>#{item.small_text}</small>" if item.small_text
      result
    templateSelection: (item) -> item.text

  @makeAjaxListSelectOptions: (url, id_attr, text_attr, small_text_attr) =>
    $.extend(@makeAjaxSelectOptions(url, id_attr, text_attr, small_text_attr),
      multiple: true
      templateSelection: (item) ->
        if item.id != item.text || ! item.selected
          "<span class='existing-item-for-list-selection'>#{item.text}</span>"
        else
          "<span class='new-item-for-list-selection'>#{item.text}</span>"
    )

  constructor: (el) ->
    @$el = $(el)

  $: (args) =>
    @$el.find(args)

  init: =>
    return unless @$el.length >= 1
    @initDirtyTracker()

  initDirtyTracker: =>
    @dirtyTracker = new DirtyTracker(@$el[0]).init()

    # TODO: make sure it works with keyboard and touch too
    $('input[type=submit][name=back]').on 'click', (event) =>
      if @dirtyTracker.isChanged()
        # TODO: use bootstrap's confirmation dialog
        unless confirm("Discard unsaved changes?")
          event.preventDefault()

class PopulationSubmission extends Submission
  defaultSelectOptions: { allowClear: true }
  plantLineSelectOptions: @makeAjaxSelectOptions('/plant_lines', 'plant_line_name', 'plant_line_name', 'common_name')
  plantLineListSelectOptions: @makeAjaxListSelectOptions('/plant_lines', 'id', 'plant_line_name', 'common_name')
  plantVarietySelectOptions: @makeAjaxSelectOptions('/plant_varieties', 'plant_variety_name', 'plant_variety_name', 'crop_type')

  init: =>
    super()

    @$('.taxonomy-term').select2(@defaultSelectOptions)
    @$('.male-parent-line, .female-parent-line').select2(@plantLineSelectOptions)
    @$('.population-type').select2(@defaultSelectOptions)
    @$('.plant-line-list').select2(@plantLineListSelectOptions)

    @bindNewPlantLineControls()

  bindNewPlantLineControls: =>
    @$('.plant-line-list').on 'select2:unselect', (event) =>
      @removeNewPlantLineFromList(event.params.data.id)

    @$('button.new-plant-line-for-list').on 'click', (event) =>
      $(event.target).hide()
      @initNewPlantLineForm()

    @$('.add-new-plant-line-for-list').on 'click', (event) =>
      @validateNewPlantLineForList(@appendToSelectedPlantLineLists)

    @$('.cancel-new-plant-line-for-list').on 'click', (event) =>
      @$('div.new-plant-line-for-list').hide()
      @$('button.new-plant-line-for-list').show()

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

class TrialSubmission extends Submission
  defaultSelectOptions: { allowClear: true }
  plantPopulationSelectOptions: @makeAjaxSelectOptions('/plant_populations', 'id', 'name', 'description')
  traitDescriptorListSelectOptions: @makeAjaxListSelectOptions('/trait_descriptors', 'id', 'descriptor_name', 'descriptor_label')

  init: =>
    super()

    @$('select.plant-population').select2(@plantPopulationSelectOptions)
    @$('select.trait-descriptor-list').select2(@traitDescriptorListSelectOptions)
    @$('select.country-id').select2(@defaultSelectOptions)

    fields = [
      'institute-id'
      'terrain'
      'soil-type'
      'statistical-factors'
      'design-factors'
    ]

    $.each fields, (_, field) =>
      @$(".#{field}").select2(@defaultSelectOptions)
      @$(".#{field}-wrapper").comboField()

    @bindUpload()
    @bindNewTraitDescriptorControls()

  bindUpload: =>
    @$('.trait-scores-upload').fileupload
      data_type: 'json'

      add: (event, data) =>
        @$('.fileinput-button').addClass('disabled')
        data.submit()

      done: (event, data) =>
        @$('#submission_content_upload_id').val(data.result.id)

        @$('.fileinput-button').removeClass('disabled').addClass('hidden')
        @$('.uploaded-trait-scores').removeClass('hidden')
        @$('.uploaded-trait-scores .file-name').text(data.result.file_file_name)
        @$('.uploaded-trait-scores .delete-trait-scores-upload').attr(href: data.result.delete_url)
        @$('.uploaded-trait-scores .parser-logs').removeClass('hidden')
        @$('.uploaded-trait-scores .parser-logs').text(data.result.logs.join('\n'))
        if data.result.errors.length > 0
          @$('.uploaded-trait-scores .parser-errors').removeClass('hidden')
          @$('.uploaded-trait-scores .parser-errors').text(data.result.errors.join('\n'))
          @$('.uploaded-trait-scores .parser-summary').addClass('hidden')
          @$('.uploaded-trait-scores .parser-summary').text('')
        else
          @$('.uploaded-trait-scores .parser-errors').addClass('hidden')
          @$('.uploaded-trait-scores .parser-errors').text('')
          @$('.uploaded-trait-scores .parser-summary').removeClass('hidden')
          @$('.uploaded-trait-scores .parser-summary').text(data.result.summary.join('\n'))

      fail: (event, data) =>
        if data.jqXHR.status == 401
          window.location.reload()

    @$('.delete-trait-scores-upload').on 'ajax:success', (data, status, xhr) =>
      @$('.fileinput-button').removeClass('hidden')
      @$('.uploaded-trait-scores').addClass('hidden')

  bindNewTraitDescriptorControls: =>
    @$('.trait-descriptor-list').on 'select2:unselect', (event) =>
      @removeNewTraitDescriptorFromList(event.params.data.id)

    @$('button.new-trait-descriptor-for-list').on 'click', (event) =>
      $(event.target).hide()
      @initNewTraitDescriptorForm()

    @$('.add-new-trait-descriptor-for-list').on 'click', (event) =>
      @validateNewTraitDescriptorForList(@appendToSelectedTraitDescriptorLists)

    @$('.cancel-new-trait-descriptor-for-list').on 'click', (event) =>
      @$('div.new-trait-descriptor-for-list').hide()
      @$('button.new-trait-descriptor-for-list').show()

  initNewTraitDescriptorForm: =>
    @$('div.new-trait-descriptor-for-list').removeClass('hidden').show()

    fields = [
      'category'
      'units-of-measurements'
      'score-type'
      'where-to-score'
    ]

    $.each fields, (_, field) =>
      @$(".#{field}").select2(@defaultSelectOptions)
      @$(".#{field}-wrapper").comboField()

    @$('.new-trait-descriptor-for-list input[type=text]').on 'keydown', (event) =>
      if event.keyCode == 13 # Enter key
        event.preventDefault() # Prevent form submission

  validateNewTraitDescriptorForList: (onValidData) =>
    $form = @$('.new-trait-descriptor-for-list')

    [data, errors] = Errors.validate($form)

    if errors.length > 0
      Errors.hideAll()
      Errors.showAll(errors)
    else
      Errors.hideAll()

      onValidData(data)

      @$('div.new-trait-descriptor-for-list').hide()
      @$('button.new-trait-descriptor-for-list').show()

  appendToSelectedTraitDescriptorLists: (data) =>
    $select = @$('.trait-descriptor-list')
    selectedValues = $select.val() || []

    $option = $('<option></option>').attr(value: data.descriptor_name).text(data.descriptor_name)
    $select.append($option)

    selectedValues.push(data.descriptor_name)
    $select.val(selectedValues)
    $select.trigger('change') # required to notify select2 about changes, see https://github.com/select2/select2/issues/3057

    # add all PL attributes to DOM so it can be sent with form
    $form = @$el.find('form')
    $container = $('<div></div').attr(id: @newTraitDescriptorForListContainerId(data.descriptor_name))
    $container.appendTo($form)

    $.each(data, (attr, val) =>
      $input = $("<input type='hidden' name='submission[content][new_trait_descriptors][][" + attr + "]' />")
      $input.val(val)
      $input.appendTo($container)
    )

  removeNewTraitDescriptorFromList: (descriptor_name) =>
    $("##{@newTraitDescriptorForListContainerId(descriptor_name)}").remove()

  newTraitDescriptorForListContainerId: (descriptor_name) =>
    'new-trait-descriptor-' + descriptor_name.split(/\s+/).join('-').toLowerCase()

$ ->
  new PopulationSubmission('.edit-population-submission').init()
  new TrialSubmission('.edit-trial-submission').init()

