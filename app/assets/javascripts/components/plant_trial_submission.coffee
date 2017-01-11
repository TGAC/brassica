window.PlantTrialSubmission = class PlantTrialSubmission extends Submission
  defaultSelectOptions: { allowClear: true }
  plantPopulationSelectOptions: @makeAjaxSelectOptions('/plant_populations', 'id', 'name', 'description')
  traitDescriptorListSelectOptions: @makeAjaxListSelectOptions('/trait_descriptors', 'id', 'trait_name', 'scoring_method')
  traitSelectOptions: @makeAjaxSelectOptions('/traits', 'name', 'name', 'description')
  plantPartSelectOptions: @makeAjaxSelectOptions('/plant_parts', 'id', 'plant_part', 'description')

  init: =>
    return unless @$el.length >= 1

    @$('select.plant-population').select2(@plantPopulationSelectOptions)
    @$('select.trait-descriptor-list').select2(@traitDescriptorListSelectOptions)
    @$('select.country-id').select2(@defaultSelectOptions)

    fields = [
      'institute-id'
      'terrain'
      'soil-type'
      'statistical-factors'
    ]

    if $('.project-descriptor-select option').length > 0
      fields.push 'project-descriptor'

    $.each fields, (_, field) =>
      @$(".#{field}").select2(@defaultSelectOptions)
      @$(".#{field}-wrapper").comboField()

    @bindTraitScoresUpload()
    @bindLayoutUpload()
    @bindNewTraitDescriptorControls()
    @bindDesignFactorNameComboFields()

    super()

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
          if data.result.warnings.length > 0
            @$('.uploaded-trait-scores .parser-warnings').removeClass('hidden')
            @$('.uploaded-trait-scores .parser-warnings').text(data.result.warnings.join('\n'))
          else
            @$('.uploaded-trait-scores .parser-warnings').addClass('hidden')
            @$('.uploaded-trait-scores .parser-warnings').text('')
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

  bindDesignFactorNameComboFields: =>
    @$(".design-factor-names").select2(@defaultSelectOptions)
    @designFactorNameComboFields = @$(".design-factor-names-wrapper").comboField()

    @designFactorNameComboFields.on('combo:select combo:clear', (ev, value) =>
      @updateDesignFactorNameComboFields($(ev.target), value, clear: true)
    )

    @designFactorNameComboFields.on('combo:input', (ev, value) =>
      @updateDesignFactorNameComboFields($(ev.target), value)
    )

    @designFactorNameComboFields.each (_, el) =>
      $el = @$(el)
      val = $el.comboField('value')
      @updateDesignFactorNameComboFields($el, val) if val.length > 0

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

  updateDesignFactorNameComboFields: ($changed, value, options = {}) =>
    $next = $changed.parents(".form-group").next()
    $nextAll = $changed.parents(".form-group").nextAll()

    if options.clear
      $nextAll.find(".design-factor-names-wrapper").comboField('clear')

    if value
      $nextAll.find("option").prop(disabled: false) if $nextAll.find("option[value=#{value}]").length > 0
      $nextAll.find("option[value=#{value}]").prop(disabled: true)
      $nextAll.find("option[value=#{value}]").prevAll().prop(disabled: true)
      $next.removeClass('hidden')

    else
      $nextAll.addClass('hidden')

    # Reset select2 so that it sees changes in disabled options
    $nextAll.find('select').select2(@defaultSelectOptions)
