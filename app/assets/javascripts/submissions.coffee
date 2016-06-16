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

    $('input[type=submit][name=back], .step a').on 'click', (event) =>
      if @dirtyTracker.isChanged()
        msg = "Discard unsaved changes?"

        target_step = $(event.target).attr("data-step-to")
        current_step = @$('form').attr("data-step")

        if Number(target_step) > Number(current_step)
          msg += "\nIf you want to save your changes click the 'Next' button " +
                 "below the form.\n"

        unless confirm(msg)
          event.preventDefault()
          event.stopPropagation()

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

  initDirtyTracker: =>
    super()

    $('input[type=submit][name=leave], input[type=submit][name=commit]').on 'click', (event) =>
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
  traitDescriptorListSelectOptions: @makeAjaxListSelectOptions('/trait_descriptors', 'id', 'trait_name', 'scoring_method')
  traitSelectOptions: @makeAjaxSelectOptions('/traits', 'name', 'name', 'description')
  plantPartSelectOptions: @makeAjaxSelectOptions('/plant_parts', 'id', 'plant_part', 'description')

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

    if $('.project-descriptor-select option').length > 0
      fields.push 'project-descriptor'

    $.each fields, (_, field) =>
      @$(".#{field}").select2(@defaultSelectOptions)
      @$(".#{field}-wrapper").comboField()

    @bindTraitScoresUpload()
    @bindLayoutUpload()
    @bindNewTraitDescriptorControls()

  initDirtyTracker: =>
    super()

    $('input[type=submit][name=leave], input[type=submit][name=commit]').on 'click', (event) =>
      if @dirtyTracker.isChanged('new-trait-descriptor')
        unless confirm("Discard new Trait descriptor?")
          event.preventDefault()
          event.stopPropagation()

  bindTraitScoresUpload: =>
    @$('.trait-scores-upload').fileupload
      data_type: 'json'

      add: (event, data) =>
        @$('.fileinput-button').addClass('disabled')
        data.submit()

      done: (event, data) =>
        $(".errors").addClass('hidden').text("")

        @$('#submission_content_upload_id').val(data.result.id)

        @$('.fileinput').addClass('hidden')
        @$('.fileinput-button').removeClass('disabled')
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
        else if data.jqXHR.status == 422
          @$('.fileinput-button').removeClass('disabled')

          $errors = $(".errors").text("").removeClass('hidden').append("<ul></ul>")
          $.each(data.jqXHR.responseJSON.errors, (_, error) =>
            $li = $("<li></li>").text(error)
            $errors.find("ul").append($li)
          )

    @$('.delete-trait-scores-upload').on 'ajax:success', (data, status, xhr) =>
      @$('.fileinput').removeClass('hidden')
      @$('.uploaded-trait-scores').addClass('hidden')

  bindLayoutUpload: =>
    @$('.layout-upload').fileupload
      data_type: 'json'

      add: (event, data) =>
        @$('.fileinput-button').addClass('disabled')
        data.submit()

      done: (event, data) =>
        $(".errors").addClass('hidden').text("")

        @$('#submission_content_layout_upload_id').val(data.result.id)

        @$('.fileinput').addClass('hidden')
        @$('.fileinput-button').removeClass('disabled')
        @$('.uploaded-layout').removeClass('hidden')
        @$('.uploaded-layout .file-name').text(data.result.file_file_name)
        @$('.uploaded-layout .delete-layout-upload').attr(href: data.result.delete_url)

        @$('.uploaded-layout .layout-image').prop(src: data.result.small_file_url)
        @$('.uploaded-layout .layout-image').parent().prop(href: data.result.original_file_url)

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

    @$('.delete-layout-upload').on 'ajax:success', (data, status, xhr) =>
      @$('.fileinput').removeClass('hidden')
      @$('.uploaded-layout').addClass('hidden')

  bindNewTraitDescriptorControls: =>
    @$('.trait-descriptor-list').on 'select2:unselect', (event) =>
      @removeNewTraitDescriptorFromList(event.params.data.id)

    @$('button.new-trait-descriptor-for-list').on 'click', (event) =>
      $(event.target).hide()
      @initNewTraitDescriptorForm()

    @$('.add-new-trait-descriptor-for-list').on 'click', (event) =>
      @validateNewTraitDescriptorForList((traitDescriptorData) =>
        @appendToSelectedTraitDescriptorLists(traitDescriptorData)
        @dirtyTracker.resetContext("new-trait-descriptor")
      )

    @$('.cancel-new-trait-descriptor-for-list').on 'click', (event) =>
      @$('div.new-trait-descriptor-for-list').hide()
      @$('button.new-trait-descriptor-for-list').show()
      @dirtyTracker.resetContext("new-trait-descriptor")

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

    @$('.trait').select2(@traitSelectOptions)
    @$('.plant-part-id').select2(@plantPartSelectOptions)

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

    $option = $('<option></option>').attr(value: data.trait).text(data.trait)
    $select.append($option)

    selectedValues.push(data.trait)
    $select.val(selectedValues)
    $select.trigger('change') # required to notify select2 about changes, see https://github.com/select2/select2/issues/3057

    # add all PL attributes to DOM so it can be sent with form
    $form = @$el.find('form')
    $container = $('<div></div').attr(id: @newTraitDescriptorForListContainerId(data.trait))
    $container.appendTo($form)

    $.each(data, (attr, val) =>
      $input = $("<input type='hidden' name='submission[content][new_trait_descriptors][][" + attr + "]' />")
      $input.val(val)
      $input.appendTo($container)
    )

  removeNewTraitDescriptorFromList: (trait) =>
    $("##{@newTraitDescriptorForListContainerId(trait)}").remove()

  newTraitDescriptorForListContainerId: (trait) =>
    'new-trait-descriptor-' + trait.split(/\s+/).join('-').toLowerCase()

$ ->
  new PopulationSubmission('.edit-population-submission').init()
  new TrialSubmission('.edit-trial-submission').init()

