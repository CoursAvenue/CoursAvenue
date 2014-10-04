
/* just a basic marionette view */
DiscoveryPassSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = FilteredSearch.Views.Map.GoogleMapsView.extend({
        infoBoxView: FilteredSearch.Views.Map.InfoBoxView,

        /* we need to center the view ourselves, since we are the data source */
        onRender: function() {
            google.maps.event.addListenerOnce(this.map, 'idle', function(){
                this.map.setZoom(11);
            }.bind(this));
        },
    });
});
