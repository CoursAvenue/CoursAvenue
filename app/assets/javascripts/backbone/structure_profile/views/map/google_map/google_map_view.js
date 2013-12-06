
/* just a basic marionette view */
StructureProfile.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        template:    '',
        markerView:  Module.MarkerView,
        infoBoxView: Module.InfoBoxView,

        /* a default InfoBoxView is provided */
        initialize: function(options) {
            /* one info window that gets populated on each marker click */
            // TODO: Should be automatic if infoBoxView is defined
            this.infoBox = new Module.InfoBoxView();
        },

        /* adds a MarkerView to the map */
        addChild: function(childModel) {
            var markerView = new this.markerView({
                model: childModel,
                map:   this.map
            });
            markerView.render();
        },

        onRender: function() {
            // TODO The following should be in the parent file IMO.
            this.$el.append(this.map_annex);
            this.centerMapAutomatically();
        },

        // TODO: This should be on the parent file and be automatic if there is no lat / lng or bbox given
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
