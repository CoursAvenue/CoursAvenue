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
            this.el    = el;
            this.morph = new Fx.Morph(this.el);
            this.hide.delay(this.options.delay, this);
        },

        hide: function() {
            this.morph.start({
                'height' : 0,
                'padding': 0
            }).chain(function() {
                this.element.destroy();
            });
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=flash]').each(function(el) {
        new GLOBAL.Objects.Flash(el);
    });
});
