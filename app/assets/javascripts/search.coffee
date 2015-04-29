class Search
  constructor: (form, results) ->
    @$form = $(form)
    @$results = $(results)

  bind: =>
    @$form.on 'submit', (event) =>
      event.preventDefault()

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

      before:
        @$results.html("<i class='fa fa-2x fa-spin fa-circle-o-notch'></i>")

      success: (response) =>
        @$results.html(response)

      complete:
        @ajax = null

$ ->
  new Search('.search', '.search-results').bind()

