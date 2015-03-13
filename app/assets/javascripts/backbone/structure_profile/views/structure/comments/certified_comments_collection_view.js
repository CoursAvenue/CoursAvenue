
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CertifiedCommentsCollectionView = Module.CommentsCollectionView.extend({
        childView: Module.CommentView,
        template: Module.templateDirname() + 'certified_comments_collection_view',
        childViewContainer: '[data-type=container]',

        announcePaginatorUpdated: function announcePaginatorUpdated () {
            // Like doing "super()"
            Module.CommentsCollectionView.prototype.announcePaginatorUpdated.apply(this, arguments);
            if (this.collection.state.grandTotal == 0) {
                this.$el.hide();
            } else {
                this.$el.show();
            }
        },

    });
});
