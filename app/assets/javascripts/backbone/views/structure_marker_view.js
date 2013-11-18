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

    /* TODO break this out into its own file (it got big...) */
    Views.StructureMarkerView = Backbone.GoogleMaps.RichMarkerView.extend({
        initialize: function (options) {

            /* TODO this setup should be done in the constructor, in the library, in another repo far, far away */
            this.$el = $("<div class='map-marker-image'><a href='javascript:void(0)'></a></div>");
            this.overlayOptions.content = this.$el[0];

            /* apparently the only way to get this done */
            this.$el.on('click', _.bind(this.markerSelected, this));
        },

        mapEvents: {
            'mouseover': 'select',
            'mouseout':  'deselect'
        },

        markerSelected: function (e) {
            this.setSelectLock(true);
            this.trigger('focus', e);
            e.stopPropagation();
        },

        select: function () {
            var self = this,
                old_top = parseInt(this.$el.css('top'), 10),
                crest = old_top - 10;

            if (!this.select_lock) {
                this.$el.addClass('active');
                this.$el.animate({ top: crest }, 200, 'linear', function () {
                    self.$el.animate({ top: old_top }, 400, 'easeOutBounce', function () {
                        console.log("boom");
                    });
                });
            }
        },

        deselect: function () {
            if (!this.select_lock) {
                this.$el.removeClass('active');
            }
        },

        setSelectLock: function (bool) {
            this.select_lock = bool;
        }
    });
});
