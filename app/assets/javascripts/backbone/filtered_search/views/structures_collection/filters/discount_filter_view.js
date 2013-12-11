
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DiscountFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'discount_filter_view',

        setup: function (data) {
            this.ui.$select.val(data.discount_types);
        },

        ui: {
            '$select': 'select'
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var value = this.ui.$select.val();
            this.trigger("filter:discount", { 'discount_types[]': value });
        }
    });
});
