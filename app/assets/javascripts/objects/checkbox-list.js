(function() {
    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.CheckboxList = new Class({

        initialize: function(el, options) {
            this.inputs_except_all = el.getElements('input:not([data-value=all])');
            this.input_all         = el.getElements('input[data-value=all]')[0];

            this.input_all.addEvent('change', function(event){
                if (this.input_all.checked) {
                    this.uncheckAllInputs();
                }
            }.bind(this));

            this.inputs_except_all.addEvent('change', function(event) {
                if (this.input_all.checked) {
                    this.input_all.checked = false;
                }
            }.bind(this));
        },

        /**
         * Will uncheck all inputs except the 'all' one
         */
        uncheckAllInputs: function() {
            this.inputs_except_all.map(function(el) {
                if (el.get('data-value') !== 'all') {
                    el.checked = false;
                }
            });
        }

    });
})();


// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=checkbox-list]').each(function(el) {
        new GLOBAL.Objects.CheckboxList(el);
    });
});
