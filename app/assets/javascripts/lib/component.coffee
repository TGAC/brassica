window.Component = class Component
  constructor: (el) ->
    @el = el
    @$el = $(el)

  $: (args) =>
    @$el.find(args)
