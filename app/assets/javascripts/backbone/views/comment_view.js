/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.CommentView = Backbone.Marionette.ItemView.extend({
        template: "backbone/templates/comment_view",
        tagName: "li",

        events: {
          'click': 'handleClick'
        },

        handleClick: function () {
          console.log("Oh, we handled that.");

        }
    });

});
