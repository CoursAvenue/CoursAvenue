FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.LocationFilterView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/location_filter_view',
        className: 'header-search-bar push-half--bottom',

        initialize: function () {
            this.announceLocation = _.debounce(this.announceLocation, 500);
        },

        events: {
            'typeahead:selected #address-picker': 'announceLocation'
        },

        announceLocation: function (e, data) {
            this.trigger("filter:location", data);
        },

        ui: {
            $address_picker: '#address-picker'
        },

        setup: function (data) {
            this.ui.$address_picker.attr('value', data.address_name);
        }

    });
});
