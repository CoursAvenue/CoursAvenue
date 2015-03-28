StructureProfile.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.StickyGoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({
        infoBoxView:  Module.InfoBoxView,

        onShow: function onShow () {
            // If the current instance is the stycky map that appears on the right of the StructureProfile
            this.$('.google-map').addClass('google-map--medium-small');
            var setStickyStyle,
                $view             = this.$el.closest('[data-type=sticky-map-container]'),
                $grid_item        = $view.closest('.grid__item'),
                initial_map_width = $view.width();
            $view.sticky({
                z        : 10,
                oldWidth : false,
                offsetTop: 72,
                stopAtEl : '#coursavenue-footer',
                onStick: function onStick () {
                    $view.css({
                        left : $grid_item.offset().left + parseInt($view.closest('.grid__item').css('padding-left'), 10) + 'px',
                        width: initial_map_width
                    });
                },
                onUnStick: function onUnStick () {
                    $view.removeAttr('style');
                }
            });
            this.recenterMap();
        },

        // We have some weird behavior having two maps on the same page...
        addChild: function addChild (childModel, html) {
            var markerView = new this.markerView({
                model:   childModel,
                map:     this.map,
                content: html
            });
            markerView.on('click'          , function() { this.markerFocus(markerView) }.bind(this));
            markerView.on('hovered'        , function() { this.markerHovered(markerView) }.bind(this));
            markerView.on('unhighlight:all', function() { this.unhighlightEveryMarker(markerView) }.bind(this));
            this.markerViewChildren[childModel.get('id')] = markerView;
            markerView.render();
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
        * Event handler for `childview:course:hovered`, as such it expects
        * a view. The view's model should have a location, and if the location
        * matches this marker's location it will get excited. */
        exciteMarkers: function exciteMarkers (data) {
            // If there are multiple ids
            if (data.place_ids) {
                _.each(this.markerViewChildren, function (child) {
                    if (data.place_ids.indexOf(child.model.get("id")) == -1) {
                        child.highlight({ show_info_box: false });
                        child.excite();
                    }
                });
            } else {
                var key = data.place_id || data.id;
                if (key === null) { return; }
                _.each(this.markerViewChildren, function (child) {
                    if (child.model.get("id") === key) {
                        child.highlight({ show_info_box: false });
                        child.excite();
                    }
                });
            }
        },

        unexciteMarkers: function exciteMarkers (data) {
            if (data.place_ids) {
                _.each(this.markerViewChildren, function (child) {
                    if (data.place_ids.indexOf(child.model.get("id")) == -1) {
                        child.unhighlight({ show_info_box: false });
                        child.calm();
                    }
                });
            } else {
                var key = data.place_id || data.id;
                if (key === null) { return; }
                _.each(this.markerViewChildren, function (child) {
                    if (child.model.get("id") === key) {
                        child.unhighlight();
                        child.calm();
                    }
                });
            }
        }
    });

}, undefined);
