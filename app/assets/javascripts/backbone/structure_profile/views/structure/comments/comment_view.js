/* just a basic marionette view */
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.CommentView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + "comment_view",
        tagName: "li",
        className: 'comment-list__el hard--left soft-half white-box',

        onRender: function () {
            this.$el.attr("id", "recommandation-" + this.model.get("id"));

        },

        events: {
          'click': 'handleClick'
        },

        handleClick: function () {
          window.location = window.location.protocol + '//' + window.location.host + '/' + this.model.get('comment_url');
        }

    });

});
