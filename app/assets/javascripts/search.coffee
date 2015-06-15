class Search
  constructor: (form, results, examples) ->
    @$form = $(form)
    @$results = $(results)
    @$examples = $(examples)

  prepare: =>
    @$form.on 'submit', (event) =>
      event.preventDefault()
      @triggerSearch()

    @$examples.on 'click', (event) =>
      event.preventDefault()
      exampleTerm = $(event.currentTarget).data('term')
      @$form.find('input[type=text]').val(exampleTerm)
      @$form.submit()

    @triggerSearch()

  triggerSearch: =>
    term = $.trim(@$form.find('input[type=text]').val())

    return if @term == term
    return unless term.length >= 2

    @performSearch(term)

  performSearch: (term) =>
    @term = term

    if @ajax
      @ajax.abort()

    @ajax = $.ajax
      url: "/search"
      dataType: 'html'
      data:
        search: term

      beforeSend: =>
        $('.search-examples').hide()
        @$results.html("<i class='fa fa-2x fa-spin fa-circle-o-notch'></i>")

      success: (response) =>
        @$results.html(response)
        @updateHistory(term)

      complete: =>
        @ajax = null

  updateHistory: (term) =>
    if window.location.search != "?search=#{term}"
      window?.history?.pushState(null, null, "/?search=#{term}")

$ ->
  new Search('.search', '.search-results', '.search-example').prepare()
