StructureProfile.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        infoBoxView:  Module.InfoBoxView,

        initialize: function(options) {
            this.sticky = this.options.sticky;
            if (this.sticky) { this.$el.addClass('soft--top'); }
        },

        onShow: function onShow () {
            if (this.sticky) {
                var $view = this.$el.parent()
                $view.sticky({ 'z': 10, old_width: false });

                // The sticky-full class needs to know about the parent's width,
                // so that we can css transition to it. Transitions between a
                // static value and a percentage don't work.
                $('<style>.sticky--full { left: ' + $view.offset().left + 30 + 'px !important; width: ' + $view.width() + 'px !important; }</style>').appendTo('head');
                $(window).resize(function () {
                    $('<style>.sticky--full { left: ' + $view.closest('.grid__item').offset().left + 30 + 'px !important; }</style>').appendTo('head');
                });
                // The map should always have sticky and sticky--full at the same
                // time. Whenever it gets or loses one of those classes, it should
                // get or lose the other. This is relevant during scroll, so we check
                // enforce it here.
                $(window).on("scroll", function () {
                    if ($view.hasClass("sticky")) {
                        $view.addClass("sticky--full");
                    } else if (!$view.hasClass("sticky") && $view.hasClass("sticky--full")) {
                        $view.removeClass("sticky--full");
                    }
                });
            } else {
                if ($(window).height() < 700) {
                    this.$el.closest('.rslides-wrapper').css('height', '30em');
                    this.$('.google-map--medium').removeClass('google-map--medium').addClass('google-map--medium-small');
                }
            }
            this.recenterMap();
        },

        // We have some weird behavior having two maps on the same page...
        addChild: function(childModel, html) {
            var markerView = new this.markerView({
                model:   childModel,
                map:     this.map,
                content: html
            });
            this.markerViewChildren[childModel.cid + (this.sticky ? 'sticky' : '')] = markerView;
            this.addChildViewEventForwarding(markerView); // buwa ha ha ha!
            markerView.render();
        },

        // We have some weird behavior having two maps on the same page...
        closeChildren: function() {
            for(var cid in this.markerViewChildren) {
                if (this.sticky && cid.indexOf('sticky') !== -1) {
                    this.closeChild(this.markerViewChildren[cid]);
                } else if (!this.sticky && cid.indexOf('sticky') === -1) {
                    this.closeChild(this.markerViewChildren[cid]);
                }
            }
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
            // Set zoom to 12 if there is only one marker
            if (this.collection.length == 1) {
                var center = new google.maps.LatLng (this.collection.first().get('location').latitude, this.collection.first().get('location').longitude)
                this.map.setCenter(center);
                this.map.setZoom(14);
            } else {
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
            }
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
