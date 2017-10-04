window.Url =
  # Extract query params from non escaped URL
  queryParams: (url) ->
    query = url.split('?')[1]

    return {} unless query

    query = query.split('#')[0]
    query = query.split("&")

    params = {}

    for param in query
      do (param) ->
        param = param.split("=")
        params[param[0]] = param[1]

    params

  replaceQueryParams: (url, params) ->
    url = url.split("?")[0]
    query = ("#{name}=#{value}" for name, value of params).join("&")

    "#{url}?#{query}"
