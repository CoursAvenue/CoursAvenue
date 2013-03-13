(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.Flash = new Class({
        Implements: Options,

        options: {
            delay: 5000
        },

        initialize: function(el, options) {
            this.setOptions(options);
            if (typeof el === 'string') {
                var flash_div = new Element('div.flash.notice');
                document.body.appendChild(flash_div);
                this.el = flash_div;
                this.el.set('text', el);
            } else {
                this.el = el;
            }
            this.el_height = this.el.getComputedSize().totalHeight;
            this.el.setStyle('top', - this.el_height);
            this.morph = new Fx.Morph(this.el);
        },
        showAndHide: function() {
            this.show();
            this.hide.delay(this.options.delay, this);
        },
        show: function() {
            return this.morph.start({
                top: 0
            });
        },
        hide: function() {
            var el_height = this.el_height;
            return this.morph.start({
                top: -el_height
            });
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=flash]').each(function(el) {
        new GLOBAL.Objects.Flash(el).showAndHide();
    });
});
