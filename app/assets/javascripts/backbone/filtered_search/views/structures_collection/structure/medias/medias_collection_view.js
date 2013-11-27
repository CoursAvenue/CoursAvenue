FilteredSearch.module('Views.PaginatedCollection.Structure.Medias', function(Module, App, Backbone, Marionette, $, _) {

    Module.MediasCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'medias_collection_view',

        // The "value" has an 's' at the end, that's what the slice is for
        itemView: Module.MediaView,
        itemViewContainer: '[data-type=container]',

        initialize: function(){
            this.on('show', function() {
                $('.media-gallery').masonry({ itemSelector: '.media__item' });
            })
        },
        onRender: function() {
            this.$('a[data-behavior="fancy"]').fancybox({ helpers : { media : {} } });
            // Using one load prevents from not triggering the event if the image is in cache
            this.$('img, iframe').one('load', function() {
                $('.media-gallery').masonry({ itemSelector: '.media__item' });
            }).each(function() { if(this.complete) $(this).load(); });;
        }
    });

});
