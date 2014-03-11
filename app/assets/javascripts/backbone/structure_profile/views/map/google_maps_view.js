StructureProfile.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GoogleMapsView = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({

        events: {
            "course:mouseenter": "exciteMarkers",
            "course:mouseleave": "exciteMarkers"
        },

        onShow: function onShow () {
            var $view = this.$el.parent(),
                $grid_item = $view.parent(),
                media_container_width = $grid_item.parent().width();

            this.$el.sticky({ 'z': 10, old_width: false });

            // The sticky-full class needs to know about the parent's width,
            // so that we can css transition to it. Transitions between a
            // static value and a percentage don't work.
            $('<style>.sticky--full { transition: width 0.5s ease; width: ' + media_container_width + 'px; }</style>').appendTo('head');

            // The map should always have sticky and sticky--full at the same
            // time. Whenever it gets or loses one of those classes, it should
            // get or lose the other. This is relevant during scroll, so we check
            // enforce it here.
            $(window).on("scroll", function () {
                if (this.$el.hasClass("sticky")) {
                    this.$el.addClass("sticky--full");

                } else if (!this.$el.hasClass("sticky") && this.$el.hasClass("sticky--full")) {
                    this.$el.removeClass("sticky--full");
                }

                this.recenterMap();
            }.bind(this));
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
            var currCenter = this.map.getCenter();

            google.maps.event.trigger(this.map, 'resize');
            this.map.setCenter(currCenter);
        },

        /* ***
        * ### \#exciteMarkers
        *
        * Event handler for `itemview:course:hovered`, as such it expects
        * a view. The view's model should have a location, and if the location
        * matches this marker's location it will get excited. */
        exciteMarkers: function exciteMarkers (view) {
            var key = view.model.get("place_id");

            if (key === null) {
                return;
            }

            _.each(this.markerViewChildren, function (child) {
                if (child.model.get("id") === key) {
                    child.toggleHighlight();

                    if (child.isHighlighted()) {
                        child.excite();
                    } else {
                        child.calm();
                    }
                }
            });
        }
    });

}, undefined);


