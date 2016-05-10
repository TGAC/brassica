# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
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
#= require_tree .

$ ->
  $('body').tooltip
    selector: '[data-toggle]'
    placement: 'top'


  bh = $('#footer').offset()
  $('.docs-sidebar').affix offset:
    top: 220
    bottom: ->
      return @bottom = - bh.top + 320

  # Handles navigation through history states originating from client-side
  # (e.g. search results)
  if window.isSafari()
    $(window).on 'popstate', (e) ->
      if e.originalEvent.state != null
        window.location.replace window.location.href
  else
    $(window).on 'popstate', ->
      window.location.replace window.location.href

  # Email address replacer
  $('.email-link').each ->
    this.setAttribute('href', this.getAttribute('href').replace('ae_address', 'Annemarie.Eckes@tgac.ac.uk'))
    this.setAttribute('href', this.getAttribute('href').replace('bip_address', 'bip@tgac.ac.uk'))
    $(this).html($(this).html().replace('bip_address', 'bip@tgac.ac.uk'))
