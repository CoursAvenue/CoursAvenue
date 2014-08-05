
/* just a basic marionette view */
CoursAvenue.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.BlankView = Marionette.ItemView.extend({ template: "" });

    Module.GoogleMapsView = Marionette.CompositeView.extend({
        template:                Module.templateDirname() + 'google_maps_view',
        className:               'map-container',

        /* while the map is a composite view, it uses
         * marker views instead of item views */
        itemView:                Module.BlankView,
        markerView:              Module.MarkerView,
        markerViewTemplate:      Module.templateDirname() + 'marker_view',
        itemViewEventPrefix:     'marker',
        markerViewChildren:      {},

        infoBoxView:         Module.InfoBoxView,

        // Test styles with google wizard: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
        styles: [
            {
                "featureType": "road",
                "elementType": "geometry.fill",
                "stylers": [
                  { "lightness": 100 }
                ]
             }, {
                "featureType": "road.highway",
                "elementType": "geometry.fill",
                "stylers": [
                  { "color": "#ffffff" },
                  { "weight": 2.5 }
                ]
              },{
                "featureType": "road.highway",
                "elementType": "geometry.stroke",
                "stylers": [
                  { "color": "#D5D5D5" },
                  { "weight": 1 }
                ]
              },{
                "featureType": "administrative",
                "elementType": "labels.text.stroke",
                "stylers": [
                  { "weight": 6 }
                ]
              },{
                "featureType": "administrative",
                "elementType": "labels.text.fill",
                "stylers": [
                  { "color": "#555555" }
                ]
              },{
                "featureType": "water",
                "elementType": "geometry.fill",
                "stylers": [
                  { "saturation": 13 },
                  { "lightness": -17 },
                  { "hue": "#0091ff" }
                ]
              },{
                "featureType": "landscape.man_made",
                "elementType": "geometry.fill",
                "stylers": [
                  { "color": "#e9E5D7" }
                ]
              }
        ],
        constructor: function (options) {
            options = options || {};
            Marionette.CompositeView.prototype.constructor.apply(this, arguments);

            var self = this;
            _.bindAll(this, 'announceBounds');

            /* default options */
            this.mapOptions = {
                center: new google.maps.LatLng(0, 0),
                zoom: 12,
                mapTypeId: google.maps.MapTypeId.ROADMAP,
                styles: this.styles
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
                // id: 'map',
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
            google.maps.event.addListener(this.map, 'dragend', function() { this.unlock('map:bounds', 'showInfoWindow'); }.bind(this));

            /* we are locking the map bounds event once, so the next time it triggers the trigger will be ignored */
            /* this prevents an infinite loop of map update at the beginning */
            this.lock('map:bounds');
            this.toggleLiveUpdate();
            this.on('marker:click'          , this.markerFocus);
            this.on('marker:hovered'        , this.markerHovered);
            this.on('marker:unhighlight:all', this.unhighlightEveryMarker);
            this.infoBox = new this.infoBoxView(options.infoBoxViewOptions || {});
        },

        onItemviewCloseClick: function onItemviewCloseClick () {
            if (this.current_info_marker) {
                this.unlockCurrentMarker();
                this.hideInfoWindow();
            }
        },

        markerHovered: function markerHovered (marker_view) {
            this.current_info_marker = marker_view.model.cid;
            // this.showInfoWindow(marker_view);
        },

        unhighlightEveryMarker: function unhighlightEveryMarker () {
            _.each(this.markerViewChildren, function(marker_view) {
                marker_view.unhighlight()
            });
        },

        markerFocus: function markerFocus (marker_view) {
            /* it seems to me this test was to ensure that re-clicking on
            * the current_info_marker wouldn't retrigger map:marker:click.
            * however, not the current_info_marker is set in markerHovered,
            * so we can avoid this check. */
            //  var marker = this.markerViewChildren[this.current_info_marker];
            //  if (marker_view === marker) {
            //      return false;
            //  }

            this.unlockCurrentMarker();

            /* TODO this is a problem, we need to not pass out the whole view, d'uh */
            this.current_info_marker = marker_view.model.cid;
            this.trigger('map:marker:click', marker_view);
        },

        unlockCurrentMarker: function unlockCurrentMarker () {
            if (this.current_info_marker) {
                var marker = this.markerViewChildren[this.current_info_marker];
                marker.setSelectLock(false);
                marker.unhighlight();
            }
        },

        liveUpdateClicked: function liveUpdateClicked (e) {
            this.update_live = e.currentTarget.checked;
            $.cookie('map:update:live', this.update_live);

            if (e.currentTarget.checked) {
                this.announceBounds();
            }

            this.toggleLiveUpdate();
        },

        toggleLiveUpdate: function toggleLiveUpdate () {
            /* set or remove a listener */
            if (this.update_live) {
                this.unlock('map:bounds', 'toggleLiveUpdate');
            } else {
                this.lock('map:bounds', 'toggleLiveUpdate');
            }
        },

        announceBounds: function announceBounds (e) {
            // we got here by a click
            if (e) { e.preventDefault(); }

            var bounds    = this.map.getBounds();
            var southWest = bounds.getSouthWest();
            var northEast = bounds.getNorthEast();
            var center    = bounds.getCenter();

            var filters = {
                'bbox_sw[]': [southWest.lat(), southWest.lng()],
                'bbox_ne[]': [northEast.lat(), northEast.lng()],
                lat: center.lat(),
                lng: center.lng()
            }

            this.trigger('map:bounds', filters);

            return false;
        },

        changeMapRadius: function changeMapRadius (data) {
            if (data.radius) {
                this.map.setZoom(data.radius);
            }
        },

        getZoomFromRadius: function getZoomFromRadius (data) {
            switch(parseFloat(data.radius)) {
              case 1: return 15;
              case 2: return 14;
              case 3: return 13;
              case 4: return 12;
              default: return 12;
            }
        },

        centerMap: function centerMap (data) {
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
            this.map.setZoom(this.getZoomFromRadius(data));
        },

        // Renders the model once, and the collection once. Calling
        // this again will tell the model's view to re-render itself
        // but the collection will not re-render.
        render: function render (){
            this.isRendered = true;
            this.isClosed   = false;
            this.resetItemViewContainer();

            this.triggerBeforeRender();
            var html = this.renderModel();
            this.$el.html(html);
            // the ui bindings is done here and not at the end of render since they
            // will not be available until after the model is rendered, but should be
            // available before the collection is rendered.
            this.bindUIElements();
            this.triggerMethod("composite:model:rendered");

            this._renderChildren();
            this.$el.find('[data-type=map-container]').prepend(this.map_annex);

            this.triggerMethod("composite:rendered");
            this.triggerRendered();
            return this;
        },

        appendHtml: function appendHtml (collectionView, itemView, index){
            /* the markerview is kind of a silly little class
            * so we are rendering its template out here, and
            * passing that in to add child. */
            var html = Marionette.Renderer.render(this.markerViewTemplate, {});
            this.addChild(itemView.model, html);
        },

        addChild: function addChild (childModel, html) {
            var markerView = new this.markerView({
                model:   childModel,
                map:     this.map,
                content: html
            });

            this.markerViewChildren[childModel.cid] = markerView;
            this.addChildViewEventForwarding(markerView); // buwa ha ha ha!
            markerView.render();
        },

        closeChildren: function closeChildren () {
            for(var cid in this.markerViewChildren) {
                this.closeChild(this.markerViewChildren[cid]);
            }
        },

        closeChild: function closeChild (child) {
            // Param can be child's model, or child view itself
            var childView = (child instanceof Backbone.Model ? this.markerViewChildren[child.cid] : child);

            childView.close();
            delete this.markerViewChildren[childView.model.cid];
        },

        /* TODO for now we are using 'cid' as the key, but
         * later I would like to use (lat,long) as the key
         * since cid is not actually an attribute and so
         * should not be included in the event from structureView
         * TODO: this todo is referenced in trello: https://trello.com/c/z8OddcYs */
        toKey: function toKey (model) {
            return model.cid;
        },

        hideInfoWindow: function hideInfoWindow () {
            this.current_info_marker = null;
            this.infoBox.close();
        },

        showInfoWindow: function showInfoWindow (view) {
            var marker = this.markerViewChildren[this.current_info_marker];
            if (!marker) { return; }

            if (this.infoBox) {
                this.infoBox.close();
            }

            /* build content for infoBox */
            // var content = view.$el.html();
            var content = view.model;

            this.infoBox.setContent(content);

            /* when the info window shows, it may cause the map to adjust. If this happens,
             * we don't want the map bounds to fire so we ignore it once */
            this.lock('map:bounds', 'showInfoWindow');
            // THIS IS VERY IMPORTANT TO KEEP USING "this.map"
            // Otherwise, on Structure#show page, when you click on a marker on
            // the right map, the infobox will not show...
            this.infoBox.open(this.map, marker.gOverlay);
        },

        serializeData: function serializeData () {
            return {
                update_live: this.update_live
            };
        }
    });
});
