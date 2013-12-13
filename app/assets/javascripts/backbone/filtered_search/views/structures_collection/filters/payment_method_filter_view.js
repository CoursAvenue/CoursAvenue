
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PaymentMethodFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'payment_method_filter_view',

        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            this.ui.$select.val(data.funding_type);
            this.announceBreadcrumb();
        },

        ui: {
            '$select': 'select'
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var payment_methods = this.ui.$select.val();
            this.trigger("filter:payment_method", { 'funding_type': payment_methods });
            this.announceBreadcrumb(payment_methods);
        },

        announceBreadcrumb: function (payment_methods) {
            payment_methods = payment_methods || this.ui.$select.val();
            if (payment_methods === null) {
                this.trigger("filter:breadcrumb:remove", {target: 'payment_method'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'payment_method'});
            }
        },

        // Clears all the given filters
        clear: function (filters) {
            this.ui.$select.val('').trigger('chosen:updated');
            this.announce();
        }
    });
});
