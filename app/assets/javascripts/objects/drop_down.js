(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.DropDown = new Class({

        initialize: function(el, options) {
            this.drop_down      = el;
            this.trigger        = $(el.get('data-trigger'));
            this.attachEvents();
        },

        attachEvents: function() {
            this.trigger.addEvent('mouseover',function(a, b) {
                this.drop_down.show();
            }.bind(this));

            this.trigger.addEvent('mouseout',function(a, b) {
                this.drop_down.hide();
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=drop-down]').each(function(el) {
        new GLOBAL.Objects.DropDown(el);
    });
});
