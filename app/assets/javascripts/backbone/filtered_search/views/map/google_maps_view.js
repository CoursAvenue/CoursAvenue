
FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        template:            Module.templateDirname() + 'google_maps_view',
        id:                  'map-container',
        itemViewEventPrefix: 'marker',
        markerView:          Module.MarkerView,
        infoBoxView:         Module.InfoBoxView,
        markerViewChildren: {},

        /* VIRTUAL method overrides */
        initialize: function(options) {
            options = options || {};

            /* one info window that gets populated on each marker click */
            this.infoBox = new Module.InfoBoxView(_.extend(options, {
                infoBoxOptions: {
                    infoBoxClearance: new google.maps.Size(100, 100)
                }
            }));
        },

        // Add a MarkerView and render
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

        /* UI and events */
        ui: {
            bounds_controls: '[data-behavior="bounds-controls"]'
        },

        events: {
            'click [data-type="closer"]':          'hideInfoWindow',
            'click [data-behavior="live-update"]': 'liveUpdateClicked'
        },

        /* lifecycle */
        onRender: function() {
            this.$el.find('[data-type=map-container]').prepend(this.map_annex);
            this.$loader = this.$('[data-type=loader]');
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
