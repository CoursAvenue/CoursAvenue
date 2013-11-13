/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.MediaView = Backbone.Marionette.ItemView.extend({
        template: "backbone/templates/media_view",
        className: 'media__item very-soft one-third',

        onRender: function() {
            this.$('a').fancybox({ helpers : { media : {} } });
            this.$('img, iframe').load(function(){
                $('.media-gallery').masonry({ itemSelector: '.media__item' });
            });
        }
    });
});
