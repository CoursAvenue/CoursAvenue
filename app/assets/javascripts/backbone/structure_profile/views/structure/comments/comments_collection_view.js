
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentsCollectionView = Marionette.CompositeView.extend({
        itemView: Module.CommentView,
        template: Module.templateDirname() + 'comments_collection_view',
        itemViewContainer: '[data-type=container]',

        initialize: function() {
            this.collection.fetch().then(function(comments) {
                this.$('[data-comments-loader]').hide();
                if (comments.length == 0) {
                    this.$('[data-empty-comments]').show();
                }
            }.bind(this));
        }
    });
});
