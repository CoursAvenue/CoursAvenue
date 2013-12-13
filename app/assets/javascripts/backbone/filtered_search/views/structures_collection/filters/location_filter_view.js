FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.LocationFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'location_filter_view',

        initialize: function () {
            this.announce = _.debounce(this.announce, 500);
        },

        setup: function (data) {
            this.ui.$address_picker.attr('value', data.address_name);
            this.announceBreadcrumb();
        },

        ui: {
            '$address_picker': '#address-picker'
        },

        events: {
            'typeahead:selected #address-picker': 'announce'
        },

        announce: function (e, data) {
            this.trigger("filter:location", data);
            this.announceBreadcrumb();
        },
        announceBreadcrumb: function() {
            if (this.ui.$address_picker.val() === 0) {
                this.trigger("filter:breadcrumb:remove", {target: 'location'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'location'});
            }
        },

        ui: {
            $address_picker: '#address-picker'
        },
        // Clears all the given filters
        clear: function (filters) {
            this.ui.$address_picker.val('');
            this.announce();
        }
    });
});
