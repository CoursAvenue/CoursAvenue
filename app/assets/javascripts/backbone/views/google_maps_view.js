
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    Views.BlankView = Marionette.ItemView.extend({ template: "" });

    /* TODO break this out into its own file (it got big...) */
    Views.StructureMarkerView = Backbone.GoogleMaps.RichMarkerView.extend({
        initialize: function (options) {

            /* TODO this setup should be done in the constructor, in the library, in another repo far, far away */
            this.$el = $("<div class='map-marker-image'><a href='javascript:void(0)'></a></div>");
            this.overlayOptions.content = this.$el[0];
        },

        mapEvents: {
            'mouseover': 'select',
            'mouseout':  'deselect'
        },

        /* TODO stupidly named event that the library forces us to use *barf* */
        toggleSelect: function (e) {
            this.trigger('focus', e);
        },

        select: function (e) {
            this.$el.addClass('active');
        },

        deselect: function (e) {
            this.$el.removeClass('active');
        }
    });

    Views.GoogleMapsView = Marionette.CompositeView.extend({
        template:            'backbone/templates/google_maps_view',
        id:                  'map-container',
        itemView:            Views.BlankView,
        itemViewEventPrefix: 'marker',
        markerView:          Views.StructureMarkerView,
        markerViewChildren: {},

        /* provide options.mapOptions to override defaults */
        initialize: function(options) {
            var self = this;
            _.bindAll(this, 'announceBounds');

            this.first_update = true;
            this.mapOptions = {
                center: new google.maps.LatLng(0, 0),
                zoom: 12,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            _.extend(this.mapOptions, options.mapOptions);

            this.mapView = new Views.BlankView({
                id: 'map',
                attributes: {
                    'class': 'map_container'
                }
            });
            this.bbox      = options.collection.getLatLngBounds().bbox;
            this.map       = new google.maps.Map(this.mapView.el, this.mapOptions);
            this.map_annex = this.mapView.el;

            /* This is to prevent the first bounds_changed event
             * The tilesloaded event is triggered after bounds_changed */
            this.bounds_has_changed_for_first_time = true;
            google.maps.event.addListenerOnce(this.map, 'tilesloaded', function(){
                self.bounds_has_changed_for_first_time = false;
            });

            this.update_live = (typeof($.cookie('map:update:live')) === 'undefined' ? 'true' : $.cookie('map:update:live'));
            if (this.update_live === 'true') {
                this.toggleLiveUpdate();
            }
        },

        ui: {
            bounds_controls: '[data-behavior="bounds-controls"]'
        },

        /* life-cycle methods */
        onMarkerFocus: function (data) {
            this.trigger('map:marker:focus', data);
        },

        onRender: function() {
            this.$el.find('[data-type=map-container]').prepend(this.map_annex);
            this.$loader = this.$('[data-type=loader]');
        },

        /* ui-events */
        events: {
            'click [data-behavior="live-update"]': 'liveUpdateClicked'
        },

        liveUpdateClicked: function (e) {
            this.update_live = e.currentTarget.checked;
            $.cookie('map:update:live', this.update_live);

            if (e.currentTarget.checked) {
                this.announceBounds();
            }

            this.toggleLiveUpdate();
        },

        toggleLiveUpdate: function () {
            /* set or remove a listener */
            if (this.update_live) {
                this.boundsChangedListener = google.maps.event.addListener(this.map, 'bounds_changed', _.debounce(this.announceBounds, 500));
            } else {
                this.boundsChangedListener = google.maps.event.removeListener(this.boundsChangedListener);
            }
        },

        announceBounds: function (e, a, b) {
            // we got here by a click
            if (e) { e.preventDefault(); }

            var bounds    = this.map.getBounds();
            var southWest = bounds.getSouthWest();
            var northEast = bounds.getNorthEast();
            var center    = bounds.getCenter();

            var filters = {
                bbox_sw: [southWest.lat(), southWest.lng()],
                bbox_ne: [northEast.lat(), northEast.lng()],
                lat: center.lat(),
                lng: center.lng()
            }
            if (!this.bounds_has_changed_for_first_time) {
                this.trigger('map:bounds', filters);
            }

            return false;
        },

        changeMapRadius: function(data) {
            if (data.radius) {
                this.map.setZoom(data.radius);
            }
        },

        centerMap: function (data) {
            if (data.lat && data.lng) {
                // More smooth than setCenter
                this.map.panTo(new google.maps.LatLng(data.lat, data.lng));
            }

            if (data.bbox) {
                if (data.bbox.sw && data.bbox.ne) {
                    var sw_latlng = new google.maps.LatLng(data.bbox.sw.lat, data.bbox.sw.lng);
                    var ne_latlng = new google.maps.LatLng(data.bbox.ne.lat, data.bbox.ne.lng);

                    var bounds = new google.maps.LatLngBounds(sw_latlng, ne_latlng);
                    this.map.fitBounds(bounds);
                }
            }

            this.map.setZoom(12);
        },

        clearForUpdate: function() {
            if (!this.first_update) {
                this.closeChildren();
                this.first_update = false;
            }
        },

        appendHtml: function(collectionView, itemView, index){
            this.addChild(itemView.model);
        },

        closeChildren: function() {
            for(var cid in this.markerViewChildren) {
                this.closeChild(this.markerViewChildren[cid]);
            }
        },

        closeChild: function(child) {
            // Param can be child's model, or child view itself
            var childView = (child instanceof Backbone.Model)? this.markerViewChildren[child.cid]: child;

            childView.close();
            delete this.markerViewChildren[childView.model.cid];
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

        /* TODO for now we are using 'cid' as the key, but
         * later I would like to use (lat,long) as the key
         * since cid is not actually an attribute and so
         * should not be included in the event from structureView */
        toKey: function (model) {
            return model.cid;
        },

        selectMarkers: function(data) {
            var self = this;

            var keys = data.map(function(model) {
                return self.toKey(model);
            });

            _.each(keys, function (key) {
                var marker = self.markerViewChildren[key];

                // Prevent from undefined
                if (marker) { marker.select(); }
            });
        },

        deselectMarkers: function (data) {
            var self = this;

            var keys = data.map(function(model) {
                return self.toKey(model);
            });

            _.each(keys, function (key) {
                var marker = self.markerViewChildren[key];

                // Prevent from undefined
                if (marker) { marker.deselect(); }
            });
        },
        serializeData: function () {
            return {
                update_live: this.update_live === 'true'
            };
        }
    });
});
