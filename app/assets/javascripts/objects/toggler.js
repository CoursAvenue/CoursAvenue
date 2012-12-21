(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Usage:
     *
     *  .my-element{data-behavior: 'toggler', el: '.css-selector'}
     *
     *  data-el: css-selector to find the associated element to toggle.
     */


    /*
     * Given an element, will toggle an associated element on click.
     */

    objects.Toggler = new Class({

        initialize: function(el, toggled_element_selector) {
            this.el = el;
            this.toggled_element = this.el.getElement(toggled_element_selector || el.get('data-el'));
            this.attach();
        },

        attach: function() {
            // Catch click on body to close the associated element if visible
            document.body.addEvent('click', function(event) {
                // Check if event.target is not contained in the associated elements to toggle
                // If the clicked element is not part of the toggled elements, we can hide them
                if (this.el.getElement(event.target) === null && this.toggled_element.getElement(event.target) === null) {
                    if (this.toggled_element.isDisplayed()) {
                        this.toggled_element.toggle();
                    }
                }
            }.bind(this));

            this.el.addEvent('click', function(event) {
                this.toggled_element.toggle();
            }.bind(this));
        }

    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=toggler]').each(function(el) {
        new GLOBAL.Objects.Toggler(el);
    });
});
