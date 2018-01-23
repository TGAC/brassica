# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require select2
#= require jquery.dataTables
#= require dataTables.tableTools
#= require dataTables.bootstrap
#= require jquery.inview
#= require jquery.easypiechart
#= require jquery.scrollTo
#= require highlight.pack
#= require cookies_eu
#= require jquery.ui.widget
#= require jquery.iframe-transport
#= require jquery.fileupload
#
#= require_directory ./lib
#= require ./components/submission
#= require_directory ./components
#= require data_grid_common_columns
#= require data_grid_specific_columns
#= require data_grid
#= require_directory .

$ ->
  $('body').tooltip
    selector: '[data-toggle]'
    placement: 'top'

  bh = $('#footer').offset()
  $('.docs-sidebar').affix offset:
    top: 220
    bottom: ->
      return @bottom = - bh.top + 320

  # Email address replacer
  $('.email-link').each ->
    this.setAttribute('href', this.getAttribute('href').replace('sarah_address', 'sarahcdyer@gmail.com'))
    this.setAttribute('href', this.getAttribute('href').replace('bip_address', 'bip@earlham.ac.uk'))
    $(this).html($(this).html().replace('bip_address', 'bip@earlham.ac.uk'))

  # Multiple form submission prevention
  $("form").not(".search").on 'submit', (event) ->
    $form = $(this)

    if $form.data('submitted')
      return event.preventDefault()

    $submits = $form.find("input[type=submit], button[type=submit]")

    if active = document.activeElement
      Button.disable(active)
      Button.disable($submits.not(active), spinner: false)
    else
      Button.disable($submits, spinner: false)

    $form.data(submitted: true)
