
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
        markerViewChildren: {},

        initialize: function(options) {
            this.mapOptions = {
                center: new google.maps.LatLng(0, 0),
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
            this.$el.find('[data-type=map-container]').prepend(this.map_annex);
        },

        centerMap: function (data) {
            console.log("GoogleMapsView->centerMap");
            if (data.lat && data.lng) {
                this.map.setCenter(new google.maps.LatLng(data.lat, data.lng));
            }
        },

        clearForUpdate: function() {
            console.log("GoogleMapsView->clearForUpdate");
            this.closeChildren();
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
            console.log("GoogleMapsView->addChild");

            var places = childModel.getRelation('places').related.models;
            var self = this;

            _.each(places, function (place) {
                var markerView = new self.markerView({
                    model: place,
                    map: self.map
                });

                self.markerViewChildren[place.cid] = markerView;

                markerView.render();
            });
        }
    });
});
