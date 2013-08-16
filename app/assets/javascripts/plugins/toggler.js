(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     *
     *  Example
     *     <h5 data-behavior='toggleable' data-el='+ .search-panel-content'>
     *         Dates
     *         <i class='icon-caret-left'></i>
     *     </h5>
     *     <div class='hide search-panel-content'>
     *          ...
     *     </div>
     */

    objects.Toggler = new Class({

        initialize: function(el, toggled_element_selector) {
            this.el         = el;
            this.caret_icon = el.getElement('i');
            this.toggled_el = el.getElement(toggled_element_selector || el.get('data-el'));
            this.morph      = new Fx.Morph(this.toggled_el, {transition: Fx.Transitions.Cubic.easeOut});
            this.attachEvents();
        },

        attachEvents: function() {
            var is_hidden       = this.toggled_el.hasClass('hide');
            var height          = this.toggled_el.offsetHeight
            var padding_top     = this.toggled_el.getStyle('padding-top');
            var padding_bottom  = this.toggled_el.getStyle('padding-bottom');
            if (is_hidden) {
                this.toggled_el.setStyles({
                    'height'        : 0,
                    'padding-top'   : 0,
                    'padding-bottom': 0
                });
                this.toggled_el.setStyle('overflow', 'hidden');
                this.toggled_el.removeClass('hide');
            }
            this.el.addEvent('click', function() {
                this.morph.cancel();
                if (is_hidden) {
                    this.caret_icon.addClass('icon-caret-down').removeClass('icon-caret-left');
                    this.morph.start({
                        'height'        : height,
                        'padding-top'   : padding_top,
                        'padding-bottom': padding_bottom
                    }).chain(function() {
                        this.toggled_el.setStyle('overflow', 'visible');
                    }.bind(this));
                } else {
                    this.caret_icon.removeClass('icon-caret-down').addClass('icon-caret-left');
                    this.toggled_el.setStyle('overflow', 'hidden');
                    this.morph.start({
                        'height'        : 0,
                        'padding-top'   : 0,
                        'padding-bottom': 0
                    });
                }
                is_hidden = !is_hidden;
            }.bind(this));
        }
    });
})();

$(function() {
    $$('[data-behavior=toggleable]').each(function(el) {
        new GLOBAL.Objects.Toggler(el);
    });
});
