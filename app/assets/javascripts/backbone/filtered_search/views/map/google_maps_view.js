
FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        template: Module.templateDirname() + 'google_maps_view',
        infoBoxView:         Module.InfoBoxView,

        /* override addchild to add one marker for each place on the model */
        addChild: function(childModel, html) {
            var places = childModel.getRelation('places').related.models;
            var self = this;

            _.each(places, function (place) {
                var markerView = new self.markerView({
                    model: place,
                    map: self.map,
                    content: html
                });

                self.markerViewChildren[place.cid] = markerView;

                // this is clever because we are "hijacking" marionette's itemview event
                // forwarding, which allows a parent to respond to child events with the
                // onItemviewMethod style of methods. Hence the "buwa ha ha ha".
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
        onRender: function onRender () {
            this.$loader = this.$('[data-type=loader]');
        },

        /* a set of markers should be made to stand out */
        exciteMarkers: function exciteMarkers (data) {
            var self = this;

            var keys = data.map(function(model) {
                return self.toKey(model);
            });

            _.each(keys, function (key) {
                var marker = self.markerViewChildren[key];

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
        }
    });
});
