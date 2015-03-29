class InputOrSelect
  constructor: (el) ->
    @$el = $(el)
    @basename = @$el.find('[name]').attr('name')

  $: (args) =>
    @$el.find(args)

  bind: =>
    $select = @$("select[name=#{@basename}]")
    $input = @$("input[name=#{@basename}]")
    $clear_input = @$("a.clear-input")

    $select.on 'select2:select', => $input.prop(disabled: true)
    $select.on 'select2:unselect', => $input.prop(disabled: false)

    $input.on 'keyup', =>
      val = $.trim($input.val())

      if val.length > 0
        $select.prop(disabled: true)
        $clear_input.removeClass('hidden')
      else
        $select.prop(disabled: false)
        $clear_inputaddClass('hidden')

    $clear_input.on 'click', (event) =>
      event.preventDefault()

      $input.val('')
      $select.prop(disabled: false)
      $clear_input.addClass('hidden')

$.fn.inputOrSelect = ->
  new InputOrSelect(this).bind()

