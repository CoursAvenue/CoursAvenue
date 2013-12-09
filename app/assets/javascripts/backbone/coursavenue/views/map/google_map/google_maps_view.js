
/* just a basic marionette view */
CoursAvenue.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.BlankView = Marionette.ItemView.extend({ template: "" });

    Module.GoogleMapsView = Marionette.CompositeView.extend({
        template:                Module.templateDirname() + 'google_maps_view',
        id:                      'map-container',

        /* while the map is a composite view, it uses
         * marker views instead of item views */
        itemView:                Module.BlankView,
        markerView:              Module.MarkerView,
        markerViewTemplate:      Module.templateDirname() + 'marker_view',
        itemViewEventPrefix:     'marker',
        markerViewChildren:      {},

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
            this.on('marker:focus', this.markerFocus);
            this.infoBox = new this.infoBoxView();
        },

        onItemviewCloseClick: function () {
            if (this.current_info_marker) {
                this.unlockCurrentMarker();
                this.hideInfoWindow();
            }
        },

        markerFocus: function (marker_view) {
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

        // Renders the model once, and the collection once. Calling
        // this again will tell the model's view to re-render itself
        // but the collection will not re-render.
        render: function(){
            this.isRendered = true;
            this.isClosed = false;
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

        appendHtml: function(collectionView, itemView, index){
            /* the markerview is kind of a silly little class
            * so we are rendering its template out here, and
            * passing that in to add child. */
            var html = Marionette.Renderer.render(this.markerViewTemplate, {});
            this.addChild(itemView.model, html);
        },

        addChild: function (childModel, html) {
            var markerView = new this.markerView({
                model:   childModel,
                map:     this.map,
                content: html
            });

            this.markerViewChildren[childModel.cid] = markerView;
            this.addChildViewEventForwarding(markerView); // buwa ha ha ha!
            markerView.render();
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
        }
    });
});
