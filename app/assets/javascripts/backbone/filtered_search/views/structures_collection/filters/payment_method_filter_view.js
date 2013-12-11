
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PaymentMethodFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'payment_method_filter_view',

        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            this.ui.$select.val(data.funding_type);
        },

        ui: {
            '$select': 'select'
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var value = this.ui.$select.val();
            this.trigger("filter:payment_method", { 'funding_type': value });
        }
    });
});
