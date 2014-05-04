StructureProfile.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        infoBoxView:  Module.InfoBoxView,

        onShow: function onShow () {
            var $view                       = this.$el.parent(),
                $grid_item                  = $view.parent(),
                $grid_parent                = $grid_item.parent();
                media_container_width       = $('#media-grid').width(),
                media_container_offset_left = $('#media-grid').offset().left;
            $grid_parent.sticky({ 'z': 10, old_width: false });

            // The sticky-full class needs to know about the parent's width,
            // so that we can css transition to it. Transitions between a
            // static value and a percentage don't work.
            $('<style>.sticky--full { left: ' + media_container_offset_left + 'px !important; width: ' + media_container_width + 'px !important; }</style>').appendTo('head');

            // The map should always have sticky and sticky--full at the same
            // time. Whenever it gets or loses one of those classes, it should
            // get or lose the other. This is relevant during scroll, so we check
            // enforce it here.
            $(window).on("scroll", function () {
                if ($grid_parent.hasClass("sticky")) {
                    $grid_parent.addClass("sticky--full grid--full");

                } else if (!$grid_parent.hasClass("sticky") && $grid_parent.hasClass("sticky--full")) {
                    $grid_parent.removeClass("sticky--full");
                }
            });
            this.recenterMap();
        },

        /* ***
         * ### \#recenterMap
         *
         * When we change the width of the map's container, we need to alert the map
         * to this by triggering resize. This will change the amount of map that is
         * shown, but won't adjust the center of the map so that it is visually centered.
         * So, in addition, we visually center the map.
         * */
        recenterMap: function recenterMap () {
            // From: http://blog.shamess.info/2009/09/29/zoom-to-fit-all-markers-on-google-maps-api-v3/
            //  Make an array of the LatLng's of the markers you want to show
            var lat_lng_list = this.collection.map(function(place) {
                return new google.maps.LatLng (place.get('location').latitude, place.get('location').longitude)
            });
            //  Create a new viewpoint bound
            var bounds = new google.maps.LatLngBounds();
            //  Go through each...
            for (var i = 0, length = lat_lng_list.length; i < length; i++) {
              //  And increase the bounds to take this point
              bounds.extend (lat_lng_list[i]);
            }
            //  Fit these bounds to the map
            this.map.fitBounds(bounds);
            // Set zoom to 12 if there is only one marker
            if (this.collection.length == 1) {
                this.map.setZoom(12);
            }
            // var currCenter = this.map.getCenter();
            // this.map.setCenter(currCenter);
            // google.maps.event.trigger(this.map, 'resize');
        },

        /* ***
        * ### \#exciteMarkers
        *
        * Event handler for `itemview:course:hovered`, as such it expects
        * a view. The view's model should have a location, and if the location
        * matches this marker's location it will get excited. */
        exciteMarkers: function exciteMarkers (data) {
            var key = data.place_id || data.id;

            if (key === null) {
                return;
            }

            _.each(this.markerViewChildren, function (child) {
                if (child.model.get("id") === key) {

                    if (child.isHighlighted()) {
                        child.unhighlight();
                        child.calm();
                    } else {
                        child.highlight({ show_info_box: false });
                        child.excite();
                    }
                }
            });
        }
    });

}, undefined);


