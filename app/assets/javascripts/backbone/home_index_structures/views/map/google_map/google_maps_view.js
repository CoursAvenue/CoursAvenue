
/* just a basic marionette view */
HomeIndexStructures.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        template: Module.templateDirname() + 'google_maps_view',
        markerView:          Module.MarkerView,
        infoBoxView:         Module.InfoBoxView,

        /* a default InfoBoxView is provided */
        initialize: function(options) {
            /* one info window that gets populated on each marker click */
            this.infoBox = new Module.InfoBoxView(options.infoBoxOptions);
        },

        /* adds a MarkerView to the map */
        addChild: function(childModel) {

            var places = childModel.getRelation('places').related.models;
            var self = this;

            _.each(places, function (place) {
                var markerView = new self.markerView({
                    model: place,
                    map: self.map
                });

                self.markerViewChildren[place.cid] = markerView;
                self.addChildViewEventForwarding(markerView); // buwa ha ha ha!

                markerView.render();
            });
        },

        /* lifecycle */
        onRender: function() {
            this.$el.append(this.map_annex);
        },

        retireMarkers: function(data) {
            this.$el.find('.map-marker-image').addClass('map-marker-image--small');
        },

        /* a set of markers should be made to stand out */
        exciteMarkers: function(data) {
            var self = this;

            var keys = data.map(function(model) {
                return self.toKey(model);
            });

            _.each(keys, function (key) {
                var marker = self.markerViewChildren[key];

                // Prevent from undefined
                if (marker) {
                    marker.toggleHighlight();

                    if (marker.isHighlighted()) {
                        marker.excite();
                    } else {
                        marker.calm();
                    }
                }
            });
        },

        togglePeacockingMarkers: function (data) {
            var self = this;

            _.each(data.keys, function (key) {
                var marker = self.markerViewChildren[key];

                if (marker) {
                    if (! marker.is_peacocking) {
                        marker.startPeacocking();
                    } else {
                        marker.stopPeacocking();
                    }
                }
            });
        }
    });
});
