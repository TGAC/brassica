
$ ->

  $('.api-live-example button').on 'click', (event) ->
    # FIXME fetch API key if user is logged in
    # api_key = ""

    url = $(event.target).data('url')
    method = $(event.target).data('method') || 'get'

    $container = $(event.target).parent()
    $container.find('.url').text(url)

    $.ajax
      url: url
      method: method
      complete: (response) =>
        json = JSON.stringify(response.responseJSON, null, 4)
        $container.find('.response code').text(json)
        $container.find('.response').removeClass('hidden')

