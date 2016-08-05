window.Button =
  disable: (el, options = { spinner: true }) ->
    $el = $(el)
    # $el.prop(disabled: true)
    $el.addClass("disabled")

    return unless options?.spinner

    $el.select('button').each (_, button) ->
      $button = $(button)
      $button.find(".fa, .icon").remove()

      if (label = $button.text()).length > 0 && $button.find("span").length == 0
        $button.html("<span>#{label}</span>")

      $button.prepend("<span class='fa fa-spin fa-circle-o-notch'></span>")
