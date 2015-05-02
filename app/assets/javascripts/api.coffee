
$ ->

  $('.api-live-example button').on 'click', (event) ->
    # FIXME fetch API key if user is logged in
    # api_key = ""

    url = $(event.target).data('url')
    method = $(event.target).data('method') || 'get'

    $container = $(event.target).parent()
    $container.find('.url').text(url)
    $code = $container.find('.response code')

    $.ajax
      url: url
      method: method
      complete: (response) =>
        json = JSON.stringify(response.responseJSON, null, 4)
        $code.text(json)
        hljs.highlightBlock($code[0])
        $container.find('.response').removeClass('hidden')

