class Submission
  @makeAjaxSelectOptions: (url, id_attr, text_attr) =>
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
      processResults: (data, page) ->
        results: $.map(data, (row) -> { id: row[id_attr], text: row[text_attr] })
    escapeMarkup: (markup) -> markup
    templateResult: (item) -> item.text
    templateSelection: (item) -> item.text

  constructor: (el) ->
    @$el = $(el)

  $: (args) =>
    @$el.find(args)

class PopulationSubmission extends Submission
  defaultSelectOptions: { allowClear: true }
  plantLineSelectOptions: @makeAjaxSelectOptions('/plant_lines', 'plant_line_name')
  plantLineListSelectOptions: $.extend(@makeAjaxSelectOptions('/plant_lines', 'plant_line_name'), multiple: true)
  plantVarietySelectOptions: @makeAjaxSelectOptions('/plant_varieties', 'plant_variety_name')

  bind: =>
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
    @$('.previous-line-name-wrapper').inputOrSelect()
    @$('.genetic-status').select2(@defaultSelectOptions)
    @$('.genetic-status-wrapper').inputOrSelect()
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
    $form = @$el
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
  plantPopulationSelectOptions: @makeAjaxSelectOptions('/plant_populations', 'id', 'name')
  traitDescriptorListSelectOptions: $.extend(@makeAjaxSelectOptions('/trait_descriptors', 'descriptor_name'), multiple: true)

  bind: =>
    @$('select.plant-population').select2(@plantPopulationSelectOptions)
    @$('select.trait-descriptor-list').select2(@traitDescriptorListSelectOptions)

    @bindNewTraitDescriptorControls()

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

    # @$('.previous-line-name').select2(@plantLineSelectOptions)
    # @$('.previous-line-name-wrapper').inputOrSelect()
    # @$('.genetic-status').select2(@defaultSelectOptions)
    # @$('.genetic-status-wrapper').inputOrSelect()
    # @$('.new-trait-descriptor-for-list input[type=text]').on 'keydown', (event) =>
    #   if event.keyCode == 13 # Enter key
    #     event.preventDefault() # Prevent form submission

    # @$('.plant-variety-name').select2(@plantVarietySelectOptions)

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
    $form = @$el
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
  new PopulationSubmission('.edit-population-submission').bind()
  new TrialSubmission('.edit-trial-submission').bind()

