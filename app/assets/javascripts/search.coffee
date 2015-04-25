$ ->
  $('.search').on 'keyup', (event) =>
    term = $('.search').val()

    console.log(term)
    return if $.trim(term).length <= 2

    $.ajax
      url: "/search"
      dataType: 'html'
      data:
        search: term
      success: (response) =>
        $('.search-results').html(response)

