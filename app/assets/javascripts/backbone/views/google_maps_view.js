FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.GoogleMapsView = Marionette.CompositeView.extend({
        template: 'backbone/templates/google_maps_view',
        id: 'map-container',

        onRender: function() {
            console.log("EVENT  GoogleMapsView->onRender");

            var mapOptions = {
                center: new google.maps.LatLng(-34.397, 150.644),
                zoom: 8,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            var mapView = new Marionette.ItemView({
                template: 'backbone/templates/_google_maps_view',
                attributes: {
                    'class': 'map_container'
                }
            });

            var map = new google.maps.Map(mapView.el, mapOptions);
            this.$el.find('[data-type=map-container]').prepend(mapView.el);

            google.maps.event.addListener(map, "idle", function(){
                map.setCenter(mapOptions.center);
                google.maps.event.trigger(map, 'resize');
            });
        }
    });
});
