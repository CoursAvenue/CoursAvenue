
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PaymentMethodFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'payment_method_filter_view',

        setup: function (data) {
            this.ui.$select.val(data.funding_type);
        },

        serializeData: function(data) {
            return { payment_methods: coursavenue.bootstrap.funding_types };
        },

        ui: {
            '$select': 'select'
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var value = this.ui.$select.val();
            console.log(value);
            this.trigger("filter:payment_method", { 'funding_type': value });
        }
    });
});
