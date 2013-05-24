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
            this.setPositionning();
            this.attachEvents();
        },

        setPositionning: function() {
            if (this.drop_down.get('data-position')) {
                switch(this.drop_down.get('data-position')) {
                    case 'right':
                        this.drop_down.setStyles({right: '0', left: 'auto'});
                        break;
                    case 'left':
                        this.drop_down.setStyles({left: '0', right: 'auto'});
                        break;
                    case 'center':
                        var demi_trigger_width = this.trigger.getDimensions().width / 2;
                        var demi_list_width    = this.drop_down.getDimensions().width / 2;
                        var left_position = demi_trigger_width - demi_list_width;
                        this.drop_down.setStyles({left: left_position, right: 'auto'});
                        break;
                }
            }
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
