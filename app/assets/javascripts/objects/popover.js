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
            document.body.appendChild(this.popover_element);
            width = (this.content.length);
            //if (width < 30) {
            this.popover_element.setStyle('margin-left', '-' + this.popover_element.getComputedSize().totalWidth / 2 + 'px');
            //}
            // Must set top property after setting width
            //this.popover_element.setStyle('top', this.popover_element.getComputedSize().totalHeight + 'px');
            this.popover_element.setStyle('top', (this.el.offsetTop - this.popover_element.getComputedSize().totalHeight) + 'px');
            this.popover_element.setStyle('left', (this.el.offsetLeft + this.el.getComputedSize().totalWidth) + 'px');
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
