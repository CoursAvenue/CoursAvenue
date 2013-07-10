(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Close a given element on click
     * data-el is the element reference to close
     */

    objects.Closer = new Class({

        initialize: function(el, options) {
            this.closer            = el;
            this.element_to_closer = $$(el.get('data-el'));
            this.attachEvents();
        },

        attachEvents: function() {
            this.closer.addEvent('click', function() {
                this.element_to_closer.dissolve();
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=closer]').each(function(el) {
        new GLOBAL.Objects.Closer(el);
    });
});
