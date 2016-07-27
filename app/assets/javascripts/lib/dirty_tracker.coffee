class DirtyTracker

  defaultContext = 'default'

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
    this.$('select, textarea, input[type=text]').filter(':enabled').each (_, el) =>
      $context = $(el).parents('[data-dirty-context]').first()
      context = $context.attr('data-dirty-context') || defaultContext
      key = @buildKey(el)

      @initialState[context] ||= {}
      @initialState[context][key] = $(el).val()

  bind: =>
    this.$('select, textarea, input[type=text]').on 'change', (event) =>
      el = event.target
      $context = $(el).parents('[data-dirty-context]').first()
      context = $context.attr('data-dirty-context') || defaultContext
      key = @buildKey(el)
      value = $(el).val()
      initialValue = @initialState[context][key]

      @changes[context] ||= {}
      @changeCounts[context] ||= 0

      if value == initialValue
        @changes[context][key] = false
        @changeCounts[context] -= 1

        unless context == defaultContext
          @changeCounts[defaultContext] -= 1

      else if !@changes[context][key]
        @changes[context][key] = true
        @changeCounts[context] += 1

        unless context == defaultContext
          @changes[defaultContext] ||= {}
          @changeCounts[defaultContext] ||= 0
          @changeCounts[defaultContext] += 1

  isChanged: (context) =>
    context ||= defaultContext

    @changeCounts[context] && @changeCounts[context] > 0

  resetContext: (context) =>
    contextCount = @changeCounts[context]
    @changeCounts[context] = 0
    @changeCounts[defaultContext] -= contextCount

    $.each @changes[context], (key) =>
      @changes[context][key] = false
      @changes[defaultContext][key] = false

  buildKey: (el) =>
    name = $(el).attr('name')
    id = $(el).attr('id')
    "#{name}/#{id}"

window.DirtyTracker = DirtyTracker
