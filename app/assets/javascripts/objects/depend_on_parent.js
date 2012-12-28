(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.DependOnParent = new Class({

        initialize: function(el, options) {
            this.parent_input = $(el.get('data-element'));
            this.inputs       = el.getElements('input');
            this.attachEvents();
        },

        attachEvents: function() {
            this.inputs.addEvent('change', function() {
                if (!this.parent_input.checked) {
                    this.parent_input.checked = true;
                    this.parent_input.fireEvent('change'); // To be sure callbacks are triggered
                }
            }.bind(this));
        }
    });
})();


// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=depend-on-parent]').each(function(el) {
        new GLOBAL.Objects.DependOnParent(el);
    });
});
