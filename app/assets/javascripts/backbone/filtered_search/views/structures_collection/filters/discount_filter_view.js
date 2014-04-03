
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DiscountFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'discount_filter_view',

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
        }.debounce(800),

        announceBreadcrumbs: function(discount_types) {
            var title;
            discount_types = discount_types || this.ui.$select.val();
            if (discount_types === null) {
                this.trigger("filter:breadcrumb:remove", {target: 'discount'});
            } else {
                title = _.map(this.ui.$select.find('option:selected'), function(option) { return $(option).text().trim() });
                this.trigger("filter:breadcrumb:add", {target: 'discount', title: title.join(', ')});
            }
        },

        // Clears all the given filters
        clear: function () {
            this.ui.$select.val('').trigger('chosen:updated');
            this.announce();
        }
    });
});
