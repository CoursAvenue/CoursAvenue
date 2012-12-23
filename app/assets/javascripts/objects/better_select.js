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
            this.el.addEvent('click', function() {
                this.select_input.replaces(this.title_wrapper);
                this.select_input.show();
            }.bind(this));

            this.select_input.addEvent('change', function(event) {
                if (event.target.getSelected()[0].get('text') !== 'Paris') {
                    alert("Nous n'avons pas encore de cours pour cette ville.\nSi toutefois vous voulez faire référencer votre cours, contactez-nous !");
                    this.select_input.getElement('option').selected = true; // Because Paris is the first option
                }
                // this.title.set('text', event.target.getSelected()[0].get('text'));
                this.title_wrapper.replaces(this.select_input);
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
