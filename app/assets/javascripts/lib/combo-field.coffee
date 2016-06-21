# Note that this widget expects the select widget to be already enhanced with
# select2.
class ComboField

  constructor: (el) ->
    @$el = $(el)
    @name = @$el.find('[name]').attr('name')

    @$input = @$("input[name='#{@name}']")
    @$select = @$("select[name='#{@name}']")
    @$clear_input = @$("a.clear-input")

  $: (args) =>
    @$el.find(args)

  init: =>
    @bind()
    @handleInitialValue()

  bind: =>
    @$select.on 'select2:select', =>
      @$input.prop(disabled: true)
      @$el.trigger('combo:change', @val())
      @$el.trigger('combo:select', @val())

    @$select.on 'select2:unselect', =>
      @$input.prop(disabled: false)
      @$el.trigger('combo:change')
      @$el.trigger('combo:clear')

    @$input.on 'keyup', =>
      @onKeyup()
      @$el.trigger('combo:change', @val())
      @$el.trigger('combo:input', @val())

    @$clear_input.on 'click', (event) =>
      event.preventDefault()
      @clearInput()
      @$el.trigger('combo:change')
      @$el.trigger('combo:clear')

  val: =>
    val = $.trim(@$select.find('option:selected').val())
    val = @$input.val() if val.length == 0
    val

  clear: =>
    @clearSelect()
    @clearInput()

  handleInitialValue: =>
    val = $.trim(@$input.val())

    return unless val.length > 0

    $option = @$select.find("[value='#{val}']")

    if $option.length > 0
      @clearInput()
      @$input.prop(disabled: true)
      @$select.val(val)
      @$select.trigger('change') # required to notify select2 about changes, see https://github.com/select2/select2/issues/3057
    else
      @onKeyup()

  onKeyup: =>
    val = $.trim(@$input.val())

    if val.length > 0
      @$select.prop(disabled: true)
      @$clear_input.removeClass('hidden')
    else
      @$select.prop(disabled: false)
      @$clear_input.addClass('hidden')

  clearInput: =>
    @$input.val('')
    @$input.trigger('change')
    @$input.prop(disabled: false)
    @$select.prop(disabled: false)
    @$clear_input.addClass('hidden')

  clearSelect: =>
    @$select.prop(disabled: false)
    @$select.find('option').prop(disabled: false, selected: false)
    @$select.trigger('change')

$.fn.comboField = (action) ->
  if action == 'value'
    values = $.map(this, (el) -> new ComboField(el).val())
    if values.length > 1
      values
    else
      values[0]

  else if action == 'clear'
    $.map(this, (el) -> new ComboField(el).clear())

  else
    $.each(this, -> new ComboField(this).init())

