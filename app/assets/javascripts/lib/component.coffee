window.Component = class Component
  constructor: (el) ->
    @$el = $(el).first()
    @el = @$el[0]

  $: (args) =>
    @$el.find(args)
