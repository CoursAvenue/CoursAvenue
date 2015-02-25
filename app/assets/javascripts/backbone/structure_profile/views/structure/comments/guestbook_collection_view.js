
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GuestbookCollectionView = Module.CommentsCollectionView.extend({
        childView: Module.CommentView,
        template: Module.templateDirname() + 'guestbook_collection_view',
        childViewContainer: '[data-type=container]'

    });
});
