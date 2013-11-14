
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    Views.BlankView = Marionette.ItemView.extend({ template: "" });

    /* TODO break this out into its own file (it got big...) */
    Views.InfoBoxView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/info_box_view',

        initialize: function (options) {
            var defaultOptions = {
                alignBottom: true,
                pixelOffset: new google.maps.Size(-150, -30),
                boxStyle: {
                    width: "300px"
                },
                enableEventPropagation: true,
                closeBoxUrl: ""
            };

            options = _.extend(defaultOptions, options);

            this.infoBox = new InfoBox(options);
            google.maps.event.addListener(this.infoBox, 'closeclick', _.bind(this.closeClick, this));
        },

        onClose: function () {
            this.infoBox.close();
        },

        closeClick: function () {
            this.trigger('closeClick');
        },

        open: function (map, marker) {
            this.infoBox.open(map, marker);
        },

        setContent: function (model) {
            this.model = model;
            this.render();

            this.infoBox.setContent(this.el);
        },

        getInfoBox: function () {
            return this.infoBox;
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

            this.mapOptions = {
                center: new google.maps.LatLng(0, 0),
                zoom: 12,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            _.extend(this.mapOptions, options.mapOptions);

            /* create mapview */
            this.mapView = new Views.BlankView({
                id: 'map',
                attributes: {
                    'class': 'map_container'
                }
            });
            this.map       = new google.maps.Map(this.mapView.el, this.mapOptions);
            this.map_annex = this.mapView.el;

            this.update_live = (typeof($.cookie('map:update:live')) === 'undefined' ? 'true' : $.cookie('map:update:live'));

            google.maps.event.addListenerOnce(this.map, 'bounds_changed', function(){
                if (self.update_live === 'true') {
                    /* this is happening too early */
                    self.toggleLiveUpdate();
                }
            });

            /* one info window that gets populated on each marker click */
            this.infoBox = new Views.InfoBoxView(options.infoBoxOptions);
            google.maps.event.addListener(this.map, 'click', _.bind(this.onItemviewCloseClick, this));
        },

        ui: {
            bounds_controls: '[data-behavior="bounds-controls"]'
        },

        events: {
            'click [data-type="closer"]': 'hideInfoWindow',
            'click [data-behavior="live-update"]': 'liveUpdateClicked'
        },

        onItemviewCloseClick: function () {
            if (this.current_info_marker) {
                this.unlockCurrentMarker();
                this.hideInfoWindow();
            }
        },

        onMarkerFocus: function (marker_view) {
            var marker = this.markerViewChildren[this.current_info_marker];
            if (marker_view === marker) {
                return false;
            }

            this.unlockCurrentMarker();

            /* TODO this is a problem, we need to not pass out the whole view, d'uh */
            this.current_info_marker = marker_view.model.cid;
            this.trigger('map:marker:focus', marker_view);
        },

        onRender: function() {
            this.$el.find('[data-type=map-container]').prepend(this.map_annex);
            this.$loader = this.$('[data-type=loader]');
        },

        unlockCurrentMarker: function () {
            if (this.current_info_marker) {
                var marker = this.markerViewChildren[this.current_info_marker];
                marker.setSelectLock(false);
                marker.deselect();
            }
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
            console.log("GoogleMapsView->announceBounds");
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

            this.trigger('map:bounds', filters);

            return false;
        },

        changeMapRadius: function(data) {
            if (data.radius) {
                this.map.setZoom(data.radius);
            }
        },

        centerMap: function (data) {
            console.log("GoogleMapsView->centerMap");
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

        hideInfoWindow: function () {
            this.current_info_marker = undefined;
            this.infoBox.close();
        },

        showInfoWindow: function (view) {
            var marker = this.markerViewChildren[this.current_info_marker];

            if (this.infoBox) {
                this.infoBox.close();
            }

            /* build content for infoBox */
            // var content = view.$el.html();
            var content = view.model;

            this.infoBox.setContent(content);
            this.infoBox.open(marker.map, marker.gOverlay);
        },

        serializeData: function () {
            return {
                update_live: this.update_live === 'true'
            };
        }
    });
});
