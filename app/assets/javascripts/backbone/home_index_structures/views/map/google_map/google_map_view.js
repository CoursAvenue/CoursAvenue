
/* just a basic marionette view */
HomeIndexStructures.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'google_map_view',
        tagName: 'li',
        className: 'google-map',
        attributes: {
            'data-behaviour': 'google-map'
        }
    });
});
