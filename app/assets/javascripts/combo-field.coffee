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
    @$select.on 'select2:select', => @$input.prop(disabled: true)
    @$select.on 'select2:unselect', => @$input.prop(disabled: false)
    @$input.on 'keyup', => @onKeyup()
    @$clear_input.on 'click', (event) =>
      event.preventDefault()
      @clearInput()

  handleInitialValue: =>
    val = $.trim(@$input.val())

    return unless val.length > 0

    $option = @$select.find("[value='#{window.escapeHtml(val)}']")

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
    @$select.prop(disabled: false)
    @$clear_input.addClass('hidden')

$.fn.comboField = ->
  new ComboField(this).init()

