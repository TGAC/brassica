
$ ->

  if $('.api-live-example').length > 0
    $.ajax
      url: "/api_key"
      method: "get"
      success: (response) =>
        window.api_key = response

  $('.api-live-example button').on 'click', (event) ->
    url = $(event.target).data('url')
    method = $(event.target).data('method') || 'get'

    $container = $(event.target).parent()
    $container.find('.url').text("#{method.toUpperCase()} #{url}")
    $container.find('button').hide()
    $code = $container.find('.response code')

    $.ajax
      url: url
      method: method
      data:
        api_key: window.api_key

      complete: (response) =>
        json = JSON.stringify(response.responseJSON, null, 4)
        $code.text(json)
        hljs.highlightBlock($code[0])
        $container.find('.response').removeClass('hidden')

