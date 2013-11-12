FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* TODO break this out into its own file (it got big...) */
    Views.StructureMarkerView = Backbone.GoogleMaps.RichMarkerView.extend({
        initialize: function (options) {

            /* TODO this setup should be done in the constructor, in the library, in another repo far, far away */
            this.$el = $("<div class='map-marker-image'><a href='javascript:void(0)'></a></div>");
            this.overlayOptions.content = this.$el[0];
        },

        mapEvents: {
            'mouseover': 'select',
            'mouseout':  'deselect'
        },

        /* TODO stupidly named event that the library forces us to use *barf* */
        toggleSelect: function (e) {
            this.setSelectLock(true);
            this.trigger('focus', e);
        },

        select: function (e) {
            if (!this.select_lock) {
                this.$el.addClass('active');
            }
        },

        deselect: function (e) {
            if (!this.select_lock) {
                this.$el.removeClass('active');
            }
        },

        setSelectLock: function (bool) {
            this.select_lock = bool;
        }
    });
});
