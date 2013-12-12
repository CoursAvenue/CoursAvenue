
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PriceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'price_filter_view',

        setup: function (data) {
            this.activateInput(data.price);
        },

        ui: {
            '$radio': '[data-behavior=radio-control]',
            '$slider': '[data-behavior=slider-control]'
        },

        events: {
            'change @ui.$radio': 'announce'
        },

        announce: function (e) {
            this.trigger("filter:price", { 'price': e.target.value });
        },

        announceRange: function (e) {
            this.trigger("filter:price", { 'price': data });
        },

        activateInput: function(value) {
            var $input = this.ui.$radio.find('[value="' + value + '"]');

            $input.prop('checked', true);
        }
    });
});
