+function($) {
  'use strict';

  // REPLACE PUBLIC CLASS DEFINITION
  // ================================

  var Replace = function (element, options) {
    this.$element      = $(element)
    this.options       = $.extend({}, Replace.DEFAULTS, options)
    this.$trigger      = $('[data-toggle="replace"][href="#' + element.id + '"],' +
                           '[data-toggle="replace"][data-target="#' + element.id + '"]')
    this.transitioning = null

    if (this.options.parent) {
      this.$parent = this.getParent()
    } else {
      this.addAriaAndReplacedClass(this.$element, this.$trigger)
    }

    if (this.options.toggle) this.toggle()
  }

  Replace.VERSION  = '0.0.1'

  Replace.TRANSITION_DURATION = 0

  Replace.DEFAULTS = {
    toggle: true
  }

  Replace.prototype.show = function () {
    if (this.transitioning || this.$element.hasClass('in')) return

    var activesData
    var actives = this.$parent && this.$parent.children('.panel').children('.in, .replacing')

    if (actives && actives.length) {
      activesData = actives.data('bs.replace')
      if (activesData && activesData.transitioning) return
    }

    var startEvent = $.Event('show.bs.replace')
    this.$element.trigger(startEvent)
    if (startEvent.isDefaultPrevented()) return

    if (actives && actives.length) {
      Plugin.call(actives, 'hide')
      activesData || actives.data('bs.replace', null)
    }

    this.$element
      .removeClass('replace')
      .addClass('replacing')
      .attr('aria-expanded', true)

    this.$trigger
      .removeClass('replaced')
      .attr('aria-expanded', true)

    this.transitioning = 1

    var complete = function () {
      this.$element
        .removeClass('replacing')
        .addClass('replace in')
      this.transitioning = 0
      this.$element
        .trigger('shown.bs.replace')
    }

    if (!$.support.transition) return complete.call(this)

    this.$element
      .one('bsTransitionEnd', $.proxy(complete, this))
      .emulateTransitionEnd(Replace.TRANSITION_DURATION)
  }

  Replace.prototype.hide = function () {
    if (this.transitioning || !this.$element.hasClass('in')) return

    var startEvent = $.Event('hide.bs.replace')
    this.$element.trigger(startEvent)
    if (startEvent.isDefaultPrevented()) return

    this.$element
      .addClass('replacing')
      .removeClass('replace in')
      .attr('aria-expanded', false)

    this.$trigger
      .addClass('replaced')
      .attr('aria-expanded', false)

    this.transitioning = 1

    var complete = function () {
      this.transitioning = 0
      this.$element
        .removeClass('replacing')
        .addClass('replace')
        .trigger('hidden.bs.replace')
    }

    if (!$.support.transition) return complete.call(this)

    this.$element
      .one('bsTransitionEnd', $.proxy(complete, this))
      .emulateTransitionEnd(Replace.TRANSITION_DURATION)
  }

  Replace.prototype.toggle = function () {
    this[this.$element.hasClass('in') ? 'hide' : 'show']()
  }

  Replace.prototype.getParent = function () {
    return $(this.options.parent)
      .find('[data-toggle="replace"][data-parent="' + this.options.parent + '"]')
      .each($.proxy(function (i, element) {
        var $element = $(element)
        this.addAriaAndReplaced(getTargetFromTrigger($element), $element)
      }, this))
      .end()
  }

  Replace.prototype.addAriaAndReplacedClass = function ($element, $trigger) {
    var isOpen = $element.hasClass('in')

    $element.attr('aria-expanded', isOpen)
    $trigger
      .toggleClass('replaced', !isOpen)
      .attr('aria-expanded', isOpen)
  }

  function getTargetFromTrigger($trigger) {
    var href
    var target = $trigger.attr('data-target')
      || (href = $trigger.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '') // strip for ie7

    return $(target)
  }


  // REPLACE PLUGIN DEFINITION
  // ==========================

  function Plugin(option) {
    return this.each(function () {
      var $this   = $(this)
      var data    = $this.data('bs.replace')
      var options = $.extend({}, Replace.DEFAULTS, $this.data(), typeof option == 'object' && option)

      if (!data && options.toggle && /show|hide/.test(option)) options.toggle = false
      if (!data) $this.data('bs.replace', (data = new Replace(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  var old = $.fn.replace

  $.fn.replace             = Plugin
  $.fn.replace.Constructor = Replace


  // REPLACE NO CONFLICT
  // ====================

  $.fn.replace.noConflict = function () {
    $.fn.replace = old
    return this
  }


  // REPLACE DATA-API
  // =================

  $(document).on('click.bs.replace.data-api', '[data-toggle="replace"]', function (e) {
    var $this   = $(this)

    if (!$this.attr('data-target')) e.preventDefault()

    var $target = getTargetFromTrigger($this)
    var data    = $target.data('bs.replace')
    var option  = data ? 'toggle' : $this.data()

    Plugin.call($target, option)
  })

}(jQuery);
