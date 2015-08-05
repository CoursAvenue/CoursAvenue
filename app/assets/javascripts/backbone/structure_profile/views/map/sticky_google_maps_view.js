StructureProfile.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.StickyGoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({

        onShow: function onShow () {
            // If the current instance is the stycky map that appears on the right of the StructureProfile
            this.$('.google-map').addClass('google-map--medium-small');
            // Stick if it has to
            var setStickyStyle,
                $view             = this.$el.closest('[data-type=sticky-map-container]'),
                $grid_item        = $view.closest('.grid__item'),
                initial_map_width = $view.width();
            $view.sticky({
                updateOnScroll: true,
                z             : 10,
                oldWidth      : false,
                offsetTop     : 50,
                stopAtEl      : '#coursavenue-footer',
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
                    if (data.place_ids.indexOf(child.model.get("id")) != -1) {
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
                    if (data.place_ids.indexOf(child.model.get("id")) != -1) {
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
