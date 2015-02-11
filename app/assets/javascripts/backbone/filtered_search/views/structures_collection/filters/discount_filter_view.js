/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DiscountFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'discount_filter_view',

        setup: function setup (data) {
            _.each(data.discount_types, function(discount_type) {
                this.activateInput(discount_type);
            } ,this);
            this.setButtonState();
        },

        ui: {
            '$buttons'             : '[data-toggle=buttons]',
            '$clear_filter_button' : '[data-behavior=clear-filter]',
            '$clearer'             : '[data-el=clearer]'
        },

        events: {
            'change input'                  : 'announce',
            'click @ui.$clear_filter_button': 'clear'
        },

        getSelectedValues: function getSelectedValues (e, data) {
            return _.map(this.$('[name="discounts[]"]:checked'), function(input){ return input.value });
        },

        announce: function announce (e, data) {
            var discount_types = this.getSelectedValues();
            this.trigger("filter:discount", { 'discount_types[]': discount_types });
            this.setButtonState(discount_types);
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        /*
         * Set the state of the button, wether or not there are filters or not
         */
        setButtonState: function setButtonState (discount_types) {
            discount_types = discount_types || this.getSelectedValues();
            if (discount_types.length > 0) {
                this.ui.$clearer.show();
                this.ui.$clear_filter_button.removeClass('btn--gray');
            } else {
                this.ui.$clear_filter_button.addClass('btn--gray')
                this.ui.$clearer.hide();
            }
        },

        activateInput: function activateInput (discount_value) {
            var $input = this.$('[value=' + discount_value + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        },

        // Clears all the given filters
        clear: function clear () {
            _.each(this.ui.$buttons.find('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.announce();
        }
    });
});
