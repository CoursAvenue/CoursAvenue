/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.CommentView = Backbone.Marionette.ItemView.extend({
        template: "backbone/templates/comment_view",
        tagName: "li",

        onRender: function () {
            // TODO Check the right method to be called after render
            var self = this;
            setTimeout(function(){
              self.$('[data-behavior=read-more]').readMore();
            });
        }
    });

});
