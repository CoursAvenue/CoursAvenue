(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.Popover = new Class({

        initialize: function(el, options) {
            this.el      = el;
            this.content = el.get('data-content');
            this.createPopoverDiv();
            this.attachEvents();
        },

        createPopoverDiv: function() {
            var width;
            this.popover_element = new Element('p.popover');
            this.popover_element.set('html', this.content)
            this.el.appendChild(this.popover_element);
            width = (this.content.length / 1.5);
            if (width < 30) {
                this.popover_element.setStyle('width', width + 'em');
                this.popover_element.setStyle('margin-left', '-' + (width / 2) + 'em');
            }
            // Must set top property after setting width
            this.popover_element.setStyle('top', '-' + this.popover_element.getComputedSize().totalHeight + 'px');
        },

        attachEvents: function() {
            this.el.addEvent('mouseover',  this.showPopover.bind(this));
            this.el.addEvent('mouseout', this.hidePopover.bind(this));
        },

        showPopover: function() {
            this.popover_element.show();
        },

        hidePopover: function() {
            this.popover_element.hide();
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=popover]').each(function(el) {
        new GLOBAL.Objects.Popover(el);
    });
});
