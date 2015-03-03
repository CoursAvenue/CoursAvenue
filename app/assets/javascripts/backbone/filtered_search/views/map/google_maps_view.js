
FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        template: Module.templateDirname() + 'google_maps_view',
        infoBoxView:         Module.InfoBoxView,

        /* override addchild to add one marker for each place on the model */
        addChild: function addChild (childModel, html) {
            var places = _.map(childModel.get('places'), function(place) { return new CoursAvenue.Models.Place(place) });

            _.each(places, function (place) {
                var markerView = new this.markerView({
                    model: place,
                    map: this.map,
                    content: html
                });

                markerView.on('click'          , function() { this.markerFocus(markerView) }.bind(this));
                markerView.on('hovered'        , function() { this.markerHovered(markerView) }.bind(this));
                markerView.on('unhighlight:all', function() { this.unhighlightEveryMarker(markerView) }.bind(this));

                this.markerViewChildren[place.id] = markerView;

                markerView.render();
            }.bind(this));
        },

        /* UI and events */
        ui: {
            '$live_update_checkbox': '[data-behavior="live-update"]'
        },

        events: {
            'click [data-type="closer"]':          'hideInfoWindow',
            'click @ui.$live_update_checkbox': 'liveUpdateClicked'
        },

        /* a set of markers should be made to stand out */
        exciteMarkers: function exciteMarkers (places) {
            var self = this;

            _.each(places, function (place) {
                var marker = self.markerViewChildren[place.id];

                // Prevent from undefined
                if (marker) {
                    if (marker.isHighlighted()) {
                        marker.calm();
                        marker.unhighlight();
                    } else {
                        marker.excite();
                        marker.highlight({show_info_box: false, unhighlight_all: false});
                    }
                }
            });
        },

        togglePeacockingMarkers: function togglePeacockingMarkers (data) {
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
        },

        setMarkerViewAndshowInfoWindow: function setMarkerViewAndshowInfoWindow (options) {
            var structure = options.structure_view.model;
            structure.set('current_location', options.location_view.model.toJSON());
            this.showInfoWindow({ model: structure });
        },

        // We lock bounds when location is updating because it will trigger the map to move and
        // we don't want the request to be fired twice.
        lockBoundsOnce: function lockBoundsOnce (childModel, html) {
            this.lock('map:bounds');
        },
        zoomOut: function zoomOut (childModel, html) {
            // Activate live update if not by default
            if (!this.update_live) {
                this.ui.$live_update_checkbox.click();
            }
            this.map.setZoom(this.map.getZoom() - 1);
        },
    });
});
