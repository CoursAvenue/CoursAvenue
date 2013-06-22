(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');


    /*
     * Given an element, will toggle an associated element on click.
     */

    objects.DroppedOptions = new Class({

        initialize: function(el) {
            this.el         = el;
            this.title      = el.getElement('.dropped-options-title');
            this.list       = this.title.getElement('+ul');
            this.titleText  = this.title.getElement('span');
            this.inputs     = el.getElements('input');

            this.attachEvents();
            this.updateTitle();
        },

        attachEvents: function() {
            this.inputs.addEvent('change', this.updateTitle.bind(this));
            this.title.addEvent('click', function() {
                this.list.toggle();
            }.bind(this));
            document.body.addEvent('click', function(event) {
                // Check if event.target is not contained in the associated elements to toggle
                // If the clicked element is not part of the toggled elements, we can hide them
                if (this.title.getElement(event.target) === null && this.list.getElement(event.target) === null) {
                    if (this.list.isDisplayed()) {
                        this.list.hide();
                    }
                }
            }.bind(this));
        },
        updateTitle: function() {
            var titles = [];
            var checked_inputs = this.inputs.filter(function(input) { return input.checked === true});
            checked_inputs.each(function(selected_input) {
                // Get associated label to
                titles.push($$('label[for='+selected_input.get('id')+']')[0].get('text'));
            });
            if (titles.length > 0) {
                this.titleText.set('text', titles.join(', '));
            }
        }

    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=dropped-options]').each(function(el) {
        new GLOBAL.Objects.DroppedOptions(el);
    });
});
