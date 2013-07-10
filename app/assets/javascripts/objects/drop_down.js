(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * data-el: CSS Selector
     */

    objects.DropDown = new Class({

        initialize: function(el, options) {
            this.trigger        = el;
            this.drop_down      = el.getElement(el.get('data-el'));
            this.position       = el.get('data-position');
            this.setPositionning();
            this.attachEvents();
        },

        setPositionning: function() {
            if (this.position) {
                switch(this.position) {
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
        var drop     = new GLOBAL.Objects.DropDown(el);
        el.drop_down = drop;
    });
});
