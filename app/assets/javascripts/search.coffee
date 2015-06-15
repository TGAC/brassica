class Search
  constructor: (form, results, examples) ->
    @$form = $(form)
    @$results = $(results)
    @$examples = $(examples)

  bind: =>
    @$form.on 'submit', (event) =>
      event.preventDefault()

      term = $.trim(@$form.find('input[type=text]').val())

      return if @term == term
      return unless term.length >= 2

      @performSearch(term)

    @$examples.on 'click', (event) =>
      exampleTerm = $(event.currentTarget).data('term')
      @$form.find('input[type=text]').val(exampleTerm)
      @$form.submit()

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

      complete:
        @ajax = null

$ ->
  new Search('.search', '.search-results', '.search-example').bind()
