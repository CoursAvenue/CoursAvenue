(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     * data-content = 'content of the popover'
     */

    objects.Popover = new Class({

        initialize: function(el, options) {
            this.el      = el;
            this.content = el.get('data-content');
            this.createPopoverDiv();
            setTimeout(this.setPopoverPosition.bind(this), 5); // To be sure that it runs last and all the dom rendering is finished
            this.attachEvents();
            this.popover_element.set('tween', {duration: 150})
        },

        createPopoverDiv: function() {
            var width;
            this.popover_element = new Element('p.popover');
            this.popover_element.set('html', this.content)
            document.body.appendChild(this.popover_element);
            width = (this.content.length);
            this.popover_element.setStyle('margin-left', '-' + this.popover_element.getComputedSize().totalWidth / 2 + 'px');
        },

        setPopoverPosition: function() {
            // Must set top property after setting width
            if (this.el.offsetTop > this.popover_element.getComputedSize().totalHeight) {
                this.popover_element.setStyle('top', (this.el.offsetTop - this.popover_element.getComputedSize().totalHeight) + 'px');
            } else {
                this.popover_element.setStyle('top', (this.el.offsetTop + this.el.getComputedSize().totalHeight) + 'px');
            }
            this.popover_element.setStyle('left', (this.el.offsetLeft + this.el.getComputedSize().totalWidth) + 'px');
        },

        attachEvents: function() {
            this.el.addEvent('mouseover', this.showPopover.bind(this));
            this.el.addEvent('mouseout',  this.hidePopover.bind(this));
        },

        showPopover: function() {
            //this.popover_element.show();
            this.popover_element.setStyle('display', 'block');
            this.popover_element.fade('in');
        },

        hidePopover: function() {
            //this.popover_element.hide();
            this.popover_element.fade('out').get('tween').chain(function() {
                this.popover_element.setStyle('display', 'none');
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=popover]').each(function(el) {
        new GLOBAL.Objects.Popover(el);
    });
});
