
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DiscountFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'discount_filter_view',

        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            this.ui.$select.val(data.discount_types);
            this.announceBreadcrumbs();
        },

        ui: {
            '$select': 'select'
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var discount_types = this.ui.$select.val();
            this.trigger("filter:discount", { 'discount_types[]': discount_types });
            this.announceBreadcrumbs(discount_types);
        },

        announceBreadcrumbs: function(discount_types) {
            discount_types = discount_types || this.ui.$select.val();
            if (discount_types === null) {
                this.trigger("filter:breadcrumb:remove", {target: 'discount'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'discount'});
            }
        },

        // Clears all the given filters
        clear: function () {
            this.ui.$select.val('').trigger('chosen:updated');
            this.announce();
        }
    });
});
