StructureProfile.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        infoBoxView:  Module.InfoBoxView,

        initialize: function(options) {
            this.sticky = this.options.sticky;
            if (this.sticky) { this.$el.addClass('soft--top'); }
        },

        onShow: function onShow () {
            // If the current instance is the stycky map that appears on the right of the StructureProfile
            if (this.sticky) {
                var setStickyStyle,
                    $view                   = this.$el.parent(),
                    $grid_item              = $view.closest('.grid__item'),
                    initial_map_width       = $view.width();
                $view.sticky({ 'z': 10, old_width: false });

                setStickyStyle = function setStickyStyle () {
                    if ($view.hasClass("sticky")) {
                        $view.css({
                            left: $grid_item.offset().left + parseInt($view.closest('.grid__item').css('padding-left'), 10) + 'px',
                            width: initial_map_width
                        });
                    } else if (!$view.hasClass("sticky") && $view.hasClass("sticky--full")) {
                        $view.removeAttr('style');
                    }
                };
                $(window).on("scroll", setStickyStyle);
                $(window).resize(setStickyStyle);
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
                var center = new google.maps.LatLng (this.collection.first().get('latitude'), this.collection.first().get('longitude'))
                this.map.setCenter(center);
                this.map.setZoom(14);
            } else {
                // From: http://blog.shamess.info/2009/09/29/zoom-to-fit-all-markers-on-google-maps-api-v3/
                //  Make an array of the LatLng's of the markers you want to show
                var lat_lng_list = this.collection.map(function(place) {
                    return new google.maps.LatLng (place.get('latitude'), place.get('longitude'))
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
