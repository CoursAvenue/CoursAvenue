
/* just a basic marionette view */
CoursAvenue.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.BlankView = Marionette.ItemView.extend({ template: "" });

    Module.GoogleMapsView = Marionette.CompositeView.extend({
        template:            '',
        id:                  'map-container',

        /* while the map is a composite view, it uses
         * marker views instead of item views */
        itemView:            Module.BlankView,
        markerView:          Module.MarkerView,
        itemViewEventPrefix: 'marker',
        markerViewChildren: {},

        infoBoxView:         Module.InfoBoxView,

        constructor: function (options) {
            options = options || {};
            Marionette.CompositeView.prototype.constructor.apply(this, arguments);

            var self = this;
            _.bindAll(this, 'announceBounds');

            /* default options */
            this.mapOptions = {
                center: new google.maps.LatLng(0, 0),
                zoom: 12,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            /* override with custom options */
            _.extend(this.mapOptions, (options.mapOptions));

            /* create mapview */
            if (options.mapClass && options.mapClass.length > 0) {
                options.mapClass = ' ' + options.mapClass;
            } else {
                options.mapClass = "";
            }

            this.mapView = new Module.BlankView({
                id: 'map',
                attributes: {
                    'class': 'map_container google-map' + options.mapClass
                }
            });

            this.map       = new google.maps.Map(this.mapView.el, this.mapOptions);
            this.map_annex = this.mapView.el;

            /* recover the user's preference */
            this.update_live = (typeof($.cookie('map:update:live')) === 'undefined' ? 'true' : $.cookie('map:update:live'));
            // Converting to boolean
            this.update_live = this.update_live === 'true';

            /* add listeners, but ignore the first bounds change */
            google.maps.event.addListener(this.map, 'click', _.bind(this.onItemviewCloseClick, this));
            google.maps.event.addListener(this.map, 'bounds_changed', _.debounce(this.announceBounds, 500));
            this.lockOnce('map:bounds');
            this.toggleLiveUpdate();
        },

        /* VIRTUAL */
        initialize: function () {
            this._throwInitializeError();
        },
        /* VIRTUAL */
        addChild: function () {
            this._throwAddChildError();
        },

        onItemviewCloseClick: function () {
            if (this.current_info_marker) {
                this.unlockCurrentMarker();
                this.hideInfoWindow();
            }
        },

        /* TODO the parent class shouldn't implement any "on" methods
        *  these should be left entirely to the extending class. So,
        *  this logic needs to move to an explicit .on('marker:focus')
        *  callback set in the constructor */
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

        unlockCurrentMarker: function () {
            if (this.current_info_marker) {
                var marker = this.markerViewChildren[this.current_info_marker];
                marker.setSelectLock(false);
                marker.toggleHighlight();
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
                this.unlock('map:bounds');
            } else {
                this.lock('map:bounds');
            }
        },

        announceBounds: function (e) {
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

        /* TODO for now we are using 'cid' as the key, but
         * later I would like to use (lat,long) as the key
         * since cid is not actually an attribute and so
         * should not be included in the event from structureView */
        toKey: function (model) {
            return model.cid;
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
            this.lockOnce('map:bounds');
            this.infoBox.open(marker.map, marker.gOverlay);
        },

        serializeData: function () {
            return {
                update_live: this.update_live
            };
        },

        _throwInitializeError: function () {
            var error = '';
            error += "GoogleMapsView is a virtual constructor!\n";
            error += "Objects extending from it must implement the following methods:\n";
            // TODO
throw(" \
GoogleMapsView is a virtual constructor!\n \
Objects extending from it must implement the following methods:\n \
\n \
    /* a default InfoBoxView is provided */\n \
    initialize: function(options) {\n \
        /* one info window that gets populated on each marker click */\n \
        this.infoBox = new Module.InfoBoxView(options.infoBoxOptions);\n \
\n \
        // ... your initialization here\n \
\n \
    },\n \
\n \
    /* adds a MarkerView to the map */\n \
    addChild: function(options) {\n \
\n \
        // ... your initialization here\n \
\n \
    },\n \
");
        },
        _throwAddChildError: function() {
throw(" \
GoogleMapsView is a virtual constructor!\n \
Objects extending from it must implement the following methods:\n \
\n \
    /* adds a MarkerView to the map */\n \
    addChild: function(child_model) {\n \
        /* here is an example implementation */\n\
        var markerView = new self.markerView({\n\
            model: child_model,\n\
            map: this.map\n\
        });\n\
\n\
        self.markerViewChildren[child_model.cid] = markerView;\n\
        self.addChildViewEventForwarding(markerView); // buwa ha ha ha!\n\
\n\
        markerView.render();\n\
\n \
    },\n \
");
        }

    });
});
