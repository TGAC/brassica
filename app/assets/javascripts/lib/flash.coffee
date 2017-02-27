window.Flash = {
  notice: (content) ->
    this.append("notice", content)

  alert: (content) ->
    this.append("alert", content)

  append: (type, content) ->
    div = "<div class='flash-#{type}'>#{content}</div>"
    $('.flash-group .container').append(div)
}
