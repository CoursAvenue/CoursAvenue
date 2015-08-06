CoursAvenue.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.BlankView = Marionette.ItemView.extend({ template: "" });

    Module.GoogleMapsView = Marionette.CompositeView.extend({
        template:                Module.templateDirname() + 'google_maps_view',
        className:               'map_container google-map',

        /* while the map is a composite view, it uses
         * marker views instead of item views */
        childView           : Module.BlankView,
        markerViewChildren  : {},

        initialize: function initialize () {
            _.bindAll(this, 'markerFocus', 'unhighlightEveryMarker');

            this.marker_layer = new L.featureGroup();

        },

        unhighlightEveryMarker: function unhighlightEveryMarker () {
            _.each(this.markerViewChildren, function(marker_view) {
                marker_view.unhighlight()
            });
        },

        markerFocus: function markerFocus (marker_view) {
            this.current_info_marker =  marker_view.model.id;
            this.trigger('map:marker:click', marker_view);
        },

        onAfterShow: function onAfterShow (){
            this.map = L.mapbox.map(this.el, 'mapbox.streets', { scrollWheelZoom: false })
                              .addLayer(this.marker_layer)
                              .setZoom(14);
            this.map.fitBounds(this.marker_layer.getBounds().pad(0.3));
            this.map.invalidateSize();
        },

        attachHtml: function attachHtml (collectionView, childView, index){
            /* the markerview is kind of a silly little class
            * so we are rendering its template out here, and
            * passing that in to add child. */
            var html = Marionette.Renderer.render(this.markerViewTemplate, {});
            this.addChild(childView.model, html);
        },

        addChild: function addChild (model, html) {
            var marker = L.marker([model.get('latitude'), model.get('longitude')], {
                icon: L.divIcon({
                    className: 'map-box-marker map-box-marker__' + window.coursavenue.bootstrap.structure.dominant_root_subject_slug,
                })
            });
            this.marker_layer.addLayer(marker);
            marker.id = model.get('id');

            var popup = L.popup({ className: 'ca-leaflet-popup' })
                .setLatLng(marker.getLatLng())
                .setContent(JST['backbone/coursavenue/templates/map/google_map/info_box_view'](model.toJSON()));
            marker.bindPopup(popup);
        }

    });
});
