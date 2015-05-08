$ ->
  if $('.api-live-example').length > 0
    hljs.initHighlightingOnLoad()

    $.ajax
      url: "/api_keys"
      format: 'json'
      method: "get"
      success: (response) =>
        console.log(response)
        window.api_key = response.api_key

  # FIXME needs refactoring
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
        text = """
        HTTP/1.1 #{response.status} #{response.statusText}
        Content-Type: #{response.getResponseHeader('Content-Type')}

        #{json}
        """

        $code.text(text)
        hljs.highlightBlock($code[0])
        $container.find('.response').removeClass('hidden')

