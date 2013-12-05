
/* just a basic marionette view */
HomeIndexStructures.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        template: Module.templateDirname() + 'google_map_view',
        tagName: 'li',
        className: 'google-map',
        attributes: {
            'data-behaviour': 'google-map'
        },

        /* a default InfoBoxView is provided */
        initialize: function(options) {
            /* one info window that gets populated on each marker click */
            this.infoBox = new Module.InfoBoxView(options.infoBoxOptions);
        },
    });
});
