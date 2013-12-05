
FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        template:            Module.templateDirname() + 'google_maps_view',
        id:                  'map-container',
        itemViewEventPrefix: 'marker',
        markerView:          Module.MarkerView,
        infoBoxView:         Module.InfoBoxView,
        markerViewChildren: {},

        initialize: function(options) {
            options = options || {};
            /* one info window that gets populated on each marker click */
            this.infoBox = new Module.InfoBoxView(_.extend(options, {
                infoBoxOptions: {
                    infoBoxClearance: new google.maps.Size(100, 100)
                }
            }));
        },
    });
});
