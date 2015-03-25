window.Errors =
  hideAll: ->
    $('.field_with_errors').each(-> Errors.hide(this))

  hide: (err) ->
    $el = $(err).children()
    $(err).before($el)
    $(err).remove()

  showAll: (elements) ->
    $.each(elements, (idx, el) -> Errors.show(el))
    $(document.body).scrollTo($(elements)[0], offset: { top: -100, left: 0 })

  show: (el) ->
    $error = $("<div class='field_with_errors'></div>")
    $(el).before($error)
    $(el).appendTo($error)

  validate: (form) ->
    data = {}
    errors = []

    attrs = $(form).find('[name]:enabled').not('[type=hidden]').map(-> this.name)
    required = $(form).find('.required, [required]').map(-> this.name)

    $.each(attrs, (idx, attr) ->
      val = $(form).find("[name=#{attr}]:enabled").val()
      data[attr] = val
      if $.inArray(attr, required) != -1 && $.trim(val) == ''
        errors.push('#' + attr)
    )

    [data, errors]

