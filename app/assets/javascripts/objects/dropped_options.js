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
            this.titleText  = this.title.getElement('span');
            this.inputs     = el.getElements('input');

            // Initializing the title to be a toggler of the list of inputs
            new GLOBAL.Objects.Toggler(this.title, '+ul');
            this.inputs.addEvent('change', this.updateTitle.bind(this));
            this.updateTitle();
        },

        updateTitle: function() {
            var titles = [];
            var checked_inputs = this.inputs.filter(function(input) { return input.checked === true});
            checked_inputs.each(function(selected_input) {
                // Get associated label to
                titles.push($$('label[for='+selected_input.get('id')+']')[0].get('text'));
            });
            this.titleText.set('text', titles.join(', '));
        }

    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=dropped-options]').each(function(el) {
        new GLOBAL.Objects.DroppedOptions(el);
    });
});
