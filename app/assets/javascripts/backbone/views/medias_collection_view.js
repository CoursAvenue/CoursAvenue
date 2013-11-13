FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.MediasCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/medias_collection_view',

        // The "value" has an 's' at the end, that's what the slice is for
        itemView: Views.MediaView,
        itemViewContainer: '[data-type=container]',

        initialize: function(){
            this.on('show', function() {
                $('.media-gallery').masonry({ itemSelector: '.media__item' });
            })
        },
        onRender: function() {
            this.$('a').fancybox({ helpers : { media : {} } });
            this.$('img, iframe').load(function(){
                $('.media-gallery').masonry({ itemSelector: '.media__item' });
            });
        }
    });

});
