FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* easing functions borroed from jQuery UI
       ref: http://stackoverflow.com/a/5207328/29182 */
    $.extend($.easing, {
        easeInBounce: function (x, t, b, c, d) {
            return c - $.easing.easeOutBounce (x, d-t, 0, c, d) + b;
        },
        easeOutBounce: function (x, t, b, c, d) {
            if ((t/=d) < (1/2.75)) {
                return c*(7.5625*t*t) + b;
            } else if (t < (2/2.75)) {
                return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
            } else if (t < (2.5/2.75)) {
                return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
            } else {
                return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
            }
        },
    });

    /* The markers! Oh the markers.
    *  hover over a marker on the map. It will be highlighted.
    *  hover over a structure in the list. All associate markers will be highlighted and excited
    *  hover over a planning in the list. The associated marker will start peacocking. */
    /* TODO markers are probably not the only element that has multiple levels of "priority".
    *  this could probably be abstracted so that the calling class sends messages like,
    *
    *    marker.priorityCode('red'); // green, blue, yellow, orange, red
    *
    *  and the receiving class defines how it reacts to the different priorities. For example,
    *  marker would have 'blue', 'green', 'yellow', and 'red' defined as:
    *
    *   blue: nothing, no highlight
    *   green: highlighted (class 'active')
    *   yellow: same as green + single bounce
    *   red: same as green + continuous bounce
    *
    *  Other classes would expose similar semantics, but implement their behaviour differently
    * */
    Views.StructureMarkerView = Backbone.GoogleMaps.RichMarkerView.extend({
        initialize: function (options) {

            /* TODO this setup should be done in the constructor, in the library, in another repo far, far away */
            this.$el = $("<div class='map-marker-image'><a href='javascript:void(0)'></a></div>");
            this.overlayOptions.content = this.$el[0];

            /* apparently the only way to get this done */
            this.$el.on('click', _.bind(this.markerSelected, this));
            this.bounce = _.debounce(this.bounce, 300);
            this.bounceOnce = _.debounce(this.bounceOnce, 300);
        },

        mapEvents: {
            'mouseover': 'toggleHighlight',
            'mouseout':  'toggleHighlight'
        },

        markerSelected: function (e) {
            this.setSelectLock(true); // while one marker is selected, the rest should be unselectable
            this.trigger('focus', e);
            e.stopPropagation();
        },

        /* a highlighted marker needs to be different from the rest */
        toggleHighlight: function () {
            if (!this.select_lock) {
                this.$el.toggleClass('active');
            }
        },

        isHighlighted: function () {
            return this.$el.hasClass('active');
        },

        /* an excited marker needs to be more than just highlighted */
        excite: function () {
            this.bounceOnce();
        },

        /* cancel an animation in progress */
        calm: function () {
            this.$el.finish();
        },

        /* a marker that should be continuously excited is peacocking */
        startPeacocking: function () {
            this.is_peacocking = true;
            this.bounce();
        },

        stopPeacocking: function () {
            this.is_peacocking = false;
            this.$el.finish();
        },

        bounceOnce: function () {
            var self = this,
                old_top = parseInt(this.$el.css('top'), 10),
                crest = old_top - 30;

            this.$el.animate({ top: crest }, 200, 'linear', function () {
                self.$el.animate({ top: old_top }, 400, 'easeOutBounce');
            });
        },

        bounce: function () {
            if (! this.is_peacocking) {
                return;
            }

            var self = this,
                old_top = parseInt(this.$el.css('top'), 10),
                crest = old_top - 30;

            this.$el.animate({ top: crest }, 200, 'linear', function () {
                self.$el.animate({ top: old_top }, 400, 'easeOutBounce', _.bind(self.bounce, self));
            });
        },

        setSelectLock: function (bool) {
            this.select_lock = bool;
        },

    });
});
