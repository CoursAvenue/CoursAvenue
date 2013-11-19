FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* TODO break this out into its own file (it got big...) */
    Views.StructureMarkerView = Backbone.GoogleMaps.RichMarkerView.extend({
        initialize: function (options) {

            /* TODO this setup should be done in the constructor, in the library, in another repo far, far away */
            this.$el = $("<div class='map-marker-image'><a href='javascript:void(0)'></a></div>");
            this.overlayOptions.content = this.$el[0];

            /* apparently the only way to get this done */
            this.$el.on('click', _.bind(this.markerSelected, this));
            this.bounce = _.debounce(this.bounce, 300);
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
                crest = old_top - 30;

            if (!this.select_lock) {
                this.$el.addClass('active');
                this.$el.animate({ top: crest }, 200, 'easeOutQuint', function () {
                    self.$el.animate({ top: old_top }, 400, 'easeOutBounce');
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
        },

        startPeacocking: function () {
            this.is_peacocking = true;
            this.bounce();
        },

        stopPeacocking: function () {
            this.is_peacocking = false;
            this.$el.finish();
        },

        bounce: function () {
            if (! this.is_peacocking) {
                return;
            }

            var self = this,
                old_top = parseInt(this.$el.css('top'), 10),
                crest = old_top - 30;

            this.$el.animate({ top: crest }, 200, 'easeOutQuint', function () {
                self.$el.animate({ top: old_top }, 400, 'easeOutBounce', _.bind(self.bounce, self));
            });
        }

    });
});
