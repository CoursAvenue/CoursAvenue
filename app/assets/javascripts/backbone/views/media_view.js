/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.MediaView = Backbone.Marionette.ItemView.extend({
        template: "backbone/templates/media_view",
        className: 'text--center',

        onRender: function() {
            this.$('a').fancybox({ helpers : { media : {} } });
        }
    });
});
