/*
 * THIS IS BAD... but...
 * I tried to have 2 instances of a Backbone GoogleMap but the markers don't get duplicated but they
 * just move from a map to another.
 * So I use GoogleMaps4Rails handler to create a map as we don't need much interaction with it.
 */
StructureProfile.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GoogleMapsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'google_maps_view',

        initialize: function initialize () {
            var google_map_handler;
            this.initializeMapHeight();
            var markers_locations = this.collection.map(function(model) {
                var infobox = new StructureProfile.Views.Map.InfoBoxView();
                infobox.setContent(model);
                // We remove the close button because it doesn't work...
                infobox.$el.find('[data-type=closer]').remove();
                return { lat: model.get('latitude'),
                         lng: model.get('longitude'),
                         marker: $("<div class='map-marker-image'><a href='javascript:void(0)'></a></div>")[0],
                         infowindow: {
                            content    : infobox.$el.html(),
                            alignBottom: true,
                            pixelOffset: new google.maps.Size(-98, -55),
                            boxStyle   : {
                                width: "200px"
                            },
                            enableEventPropagation: true
                         }
                       }
            })

            google_map_handler = Gmaps.build('Google', { builders: { Marker: GMapsCoursAvenueBuilder } } );
            google_map_handler.buildMap({ provider: { scrollwheel: false,
                                                      center     : new google.maps.LatLng(47, 2.3417),
                                                      zoom       : 14 },
                                          internal: { id: 'structure-profile-map' } },
                                          function() {
                markers = google_map_handler.addMarkers(markers_locations);
                google_map_handler.bounds.extendWith(markers);
                google_map_handler.fitMapToBounds();
                // Zoom out in case there is only two markers and they are at the
                // extreme borders of the maps
                var map = google_map_handler.getMap();
                map.setZoom(map.getZoom() - 1);
                if (google_map_handler.getMap().getZoom() > 15) {
                    google_map_handler.getMap().setZoom(15);
                }
            });
        },
        initializeMapHeight: function initializeMapHeight () {
            if ($(window).height() < 900) {
                $('.rslides-wrapper').css('height', '27em');
                this.$('.google-map--medium').removeClass('google-map--medium').addClass('google-map--medium--smaller')
            }
        }
    });

}, undefined);
