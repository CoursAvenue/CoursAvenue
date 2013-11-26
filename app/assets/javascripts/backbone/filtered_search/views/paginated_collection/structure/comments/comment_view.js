/* just a basic marionette view */
FilteredSearch.module('Views.PaginatedCollection.Structure.Comments', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.CommentView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + "comment_view",
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
