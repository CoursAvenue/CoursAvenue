/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.CommentView = Backbone.Marionette.ItemView.extend({
        template: "backbone/templates/comment_view",
        tagName: "li",
        className: 'structure-item__comment-item',

        events: {
          'click': 'handleClick'
        },

        handleClick: function () {
          window.location = window.location.protocol + '//' + window.location.host + '/' + this.model.get('comment_url');
        }
    });

});
