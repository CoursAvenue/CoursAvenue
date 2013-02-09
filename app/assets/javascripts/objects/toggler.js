(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.Toggler = new Class({

        initialize: function(el, toggled_element_selector) {
            this.el         = el;
            this.caret_icon = el.getElement('i');
            this.toggled_el = el.getElement(toggled_element_selector || el.get('data-el'));
            this.morth      = new Fx.Morph(this.toggled_el, {transition: Fx.Transitions.Cubic.easeOut});
            this.attachEvents();
        },

        attachEvents: function() {
            var toggle          = true;
            var height          = this.toggled_el.getStyle('height');
            var padding_top     = this.toggled_el.getStyle('padding-top');
            var padding_bottom  = this.toggled_el.getStyle('padding-bottom');
            this.el.addEvent('click', function() {
                this.morth.cancel();
                if (toggle) {
                    this.caret_icon.removeClass('icon-caret-down').addClass('icon-caret-left');
                    this.morth.start({
                        'height'        : 0,
                        'padding-top'   : 0,
                        'padding-bottom': 0
                    });
                } else {
                    this.caret_icon.addClass('icon-caret-down').removeClass('icon-caret-left');
                    this.morth.start({
                        'height'        : height,
                        'padding-top'   : padding_top,
                        'padding-bottom': padding_bottom
                    });
                }
                toggle = !toggle;
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=toggleable]').each(function(el) {
        new GLOBAL.Objects.Toggler(el);
    });
});
