
/* just a basic marionette view */
StructureProfile.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        infoBoxView: Module.InfoBoxView,

        onMarkerFocus: function (view) {
            this.showInfoWindow(view);
        },

        /* we need to center the view ourselves, since we are the data source */
        onRender: function() {
            this.centerMapAutomatically();
            google.maps.event.addListenerOnce(this.map, 'idle', function(){
                if (this.map.getZoom() > 15) {
                    this.map.setZoom(15);
                }
            }.bind(this));

        },

        /* TODO we could probably tweek GoogleMapsView.centerMap to work like
         * this if passed a collection */
        /* TODO if we have a bunch of map markers already, then we should
        * automatically center to them after appending them all in the 'render'
        * method */
        centerMapAutomatically:  function () {
            var latlngbounds = new google.maps.LatLngBounds();
            this.collection.each(function(model){
               latlngbounds.extend(model.getLatLng());
            });
            this.map.setCenter(latlngbounds.getCenter());
            this.map.fitBounds(latlngbounds);
        }

    });
});
