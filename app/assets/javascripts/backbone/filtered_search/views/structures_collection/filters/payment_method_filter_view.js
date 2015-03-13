
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PaymentMethodFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'payment_method_filter_view',

        setup: function (data) {
            this.ui.$select.val(data.funding_type_ids);
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
            this.trigger("filter:payment_method", { 'funding_type_ids[]': payment_methods });
            this.announceBreadcrumb(payment_methods);
        }.debounce(COURSAVENUE.constants.DEBOUNCE_DELAY),

        announceBreadcrumb: function (payment_methods) {
            var title;
            payment_methods = payment_methods || this.ui.$select.val();
            if (payment_methods === null) {
                this.trigger("filter:breadcrumb:remove", {target: 'payment_method'});
            } else {
                title = _.map(this.ui.$select.find('option:selected'), function(option) { return $(option).text().trim() });
                this.trigger("filter:breadcrumb:add", {target: 'payment_method', title: title.join(', ')});
            }
        },

        // Clears all the given filters
        clear: function (filters) {
            this.ui.$select.val('').trigger('chosen:updated');
            this.announce();
        }
    });
});
