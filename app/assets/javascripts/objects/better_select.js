(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.BetterSelect = new Class({

        initialize: function(el, options) {
            this.el             = el;
            this.select_input   = el.getElement('select');
            this.title          = el.getElement('.chooser-title');
            this.title_wrapper  = el.getElement('.chooser-title-wrapper');
            this.attachEvents();
        },

        attachEvents: function() {
            this.title_wrapper.addEvent('click', function() {
                this.title_wrapper.hide();
                this.select_input.show();
            }.bind(this));

            this.select_input.addEvent('change', function(event) {
                this.title.set('text', event.target.getSelected()[0].get('text'));
                this.title_wrapper.show();
                this.select_input.hide();
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=better-select]').each(function(el) {
        new GLOBAL.Objects.BetterSelect(el);
    });
});
