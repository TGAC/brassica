class DirtyTracker

  defaultContext: 'default'

  constructor: (el) ->
    @$el = $(el)
    @initialState = {}
    @changes = {}
    @changeCounts = {}

  $: (args) =>
    @$el.find(args)

  init: =>
    @storeInitialState()
    @bind()
    this

  storeInitialState: =>
    this.$('select, textarea, input[type=text]').each (_, el) =>
      $context = $(el).parents('[data-dirty-context]').first()
      context = $context.attr('data-dirty-context') || @defaultContext
      name = $(el).attr('name')

      @initialState[context] ||= {}
      @initialState[context][name] = $(el).val()

  bind: =>
    this.$('select, textarea, input[type=text]').on 'change', (event) =>
      el = event.target
      $context = $(el).parents('[data-dirty-context]').first()
      context = $context.attr('data-dirty-context') || @defaultContext
      name = $(el).attr('name')
      value = $(el).val()
      initialValue = @initialState[context][name]

      @changes[context] ||= {}
      @changeCounts[context] ||= 0

      if value == initialValue
        @changes[context][name] = false
        @changeCounts[context] -= 1

        unless context == @defaultContext
          @changeCounts[defaultContext] -= 1

      else if !@changes[context][name]
        @changes[context][name] = true
        @changeCounts[context] += 1

        unless context == @defaultContext
          @changeCounts[defaultContext] += 1

  isChanged: (context) =>
    context ||= @defaultContext

    @changeCounts[context] && @changeCounts[context] > 0

window.DirtyTracker = DirtyTracker
