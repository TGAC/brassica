class DirtyTracker

  defaultContext: 'sdasdasd'

  constructor: (el) ->
    @$el = $(el)
    @changes = {}
    @changeCounts = {}

  $: (args) =>
    @$el.find(args)

  init: =>
    # FIXME store initial values so that changes to initial value can decrement counters
    @bind()
    this

  bind: =>
    $('select, textarea, input[type=text]').on 'change', (event) =>
      el = event.target
      $context = $(el).parents('[data-dirty-context]').first()
      context = $context.attr('data-dirty-context') || @defaultContext
      name = $(el).attr('name')

      @changes[context] ||= {}
      @changeCounts[context] ||= 0

      unless @changes[context][name]
        @changes[context][name] = true
        @changeCounts[context] += 1

        unless context == @defaultContext
          @changeCounts[defaultContext] += 1

      # console.log(@changeCounts[context])

  isChanged: (context) =>
    context ||= @defaultContext

    @changeCounts[context] && @changeCounts[context] > 0

window.DirtyTracker = DirtyTracker
