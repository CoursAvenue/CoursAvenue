
/* TODO think about how the map will update when elements are removed or
* added. We need to do things like clear the map, and emit events when
* the map bounds are changed. ETC */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    Views.BlankView = Marionette.ItemView.extend({ template: "" });

    Views.GoogleMapsView = Marionette.CompositeView.extend({
        template: 'backbone/templates/google_maps_view',
        id: 'map-container',
        itemView: Views.BlankView,
        markerView: Backbone.GoogleMaps.MarkerView,

        initialize: function(options) {
            console.log("GoogleMapsView->initialize");
            var mapOptions = {
                center: new google.maps.LatLng(-34.397, 150.644),
                zoom: 8,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            var mapView = new Views.BlankView({
                id: 'map',
                attributes: {
                    'class': 'map_container'
                }
            });

            this.map = new google.maps.Map(mapView.el, mapOptions);
            this.map_annex = mapView.el;
        },

        onRender: function() {
            console.log("EVENT  GoogleMapsView->onRender");

            this.$el.find('[data-type=map-container]').prepend(this.map_annex);

            var self = this;
            google.maps.event.addListener(this.map, "idle", function(){
                self.map.setCenter(mapOptions.center);
                google.maps.event.trigger(self.map, 'resize');
            });
        },

        updateMap: function() {
            console.log("GoogleMapsView->updateMap");
        },

        appendHtml: function(collectionView, itemView, index){
            console.log('GoogleMapsView->appendHtml');
            this.addChild(itemView.model);
        },

        collectionEvents: {
            'add': 'addChild'
        },

        // Add a MarkerView and render
        addChild: function(childModel) {
            console.log('GoogleMapsView->addChild');
            var self = this;
            var markerView = new this.markerView({
                model: childModel,
                map: self.map
            });

            markerView.render();
        }
    });
});
