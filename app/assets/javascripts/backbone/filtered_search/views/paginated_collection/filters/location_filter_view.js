FilteredSearch.module('Views.PaginatedCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.LocationFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'location_filter_view',

        initialize: function () {
            this.announceLocation = _.debounce(this.announceLocation, 500);
        },

        setup: function (data) {
            this.ui.$address_picker.attr('value', data.address_name);
        },

        events: {
            'typeahead:selected #address-picker': 'announceLocation'
        },

        announceLocation: function (e, data) {
            this.trigger("filter:location", data);
        },

        ui: {
            $address_picker: '#address-picker'
        }
    });
});
