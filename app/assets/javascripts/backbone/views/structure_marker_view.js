FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

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
            console.log("markerSelected");
            this.setSelectLock(true);
            this.trigger('focus', e);
            e.stopPropagation();
        },

        select: function () {
            if (!this.select_lock) {
                this.$el.addClass('active');
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
