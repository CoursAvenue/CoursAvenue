
/* TODO think about how the map will update when elements are removed or
* added. We need to do things like clear the map, and emit events when
* the map bounds are changed. ETC */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    Views.BlankView = Marionette.ItemView.extend({ template: "" });

    Views.GoogleMapsView = Marionette.CompositeView.extend({
        template: 'backbone/templates/google_maps_view',
        id:       'map-container',
        itemView: Views.BlankView,
        markerView: Backbone.GoogleMaps.MarkerView,

        initialize: function(options) {
            console.log("GoogleMapsView->initialize");
            this.markers = [];
            this.mapOptions = {
                // TODO: Those coordinates should be taken from the url parameters
                center: new google.maps.LatLng(48.8592, 2.3417),
                zoom: 12,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            this.mapView = new Views.BlankView({
                id: 'map',
                attributes: {
                    'class': 'map_container'
                }
            });
            this.map = new google.maps.Map(this.mapView.el, this.mapOptions);
            this.map_annex = this.mapView.el;
        },

        onRender: function() {
            console.log("EVENT  GoogleMapsView->onRender");

            this.$el.find('[data-type=map-container]').prepend(this.map_annex);

            var self = this;
            google.maps.event.addListener(this.map, "idle", function(){
                self.map.setCenter(self.mapOptions.center);
                google.maps.event.trigger(self.map, 'resize');
            });
        },

        updateMap: function() {
            this.removeMarkers(); // TODO: Is it at the right place?
            console.log("GoogleMapsView->updateMap");
        },

        appendHtml: function(collectionView, itemView, index){
            console.log('GoogleMapsView->appendHtml');
            this.addChild(itemView.model);
        },

        collectionEvents: {
            'add': 'addChild'
        },

        removeMarkers: function() {
            _.each(this.markers, function(marker){
                marker.map = null;
                marker.remove();
            });
            this.markersArray = [];
        },

        // Add a MarkerView and render
        addChild: function(childModel) {
            console.log('GoogleMapsView->addChild');

            var markerView = new this.markerView({
                model: childModel,
                map: this.map
            });

            this.markers.push(markerView);
            markerView.render();
        }
    });
});
