FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.LocationFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'location_filter_view',

        setup: function setup (data) {
            if (data.address_name) { data.address_name = data.address_name.replace('+', ' '); }
            this.ui.$address_picker.attr('value', data.address_name);
        },

        ui: {
            '$address_picker': '#address-picker'
        },

        events: {
            'typeahead:selected #address-picker': 'announce'
        },

        onRender: function onRender() {
            this.ui.$address_picker.addressPicker();
        },

        announce: function announce (e, data) {
            this.trigger("filter:location", data);
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        ui: {
            $address_picker: '#address-picker'
        },
        // Clears all the given filters
        clear: function clear (filters) {
            this.ui.$address_picker.val('');
            this.announce();
        }
    });
});
