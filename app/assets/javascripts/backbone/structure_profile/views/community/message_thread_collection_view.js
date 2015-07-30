StructureProfile.module('Views.Community', function(Module, App, Backbone, Marionette, $, _, undefined) {
    Module.MessageThreadCollectionView = Marionette.CompositeView.extend({
        childView: Module.MessageThreadView,
        template: Module.templateDirname() + 'message_thread_collection_view',
        childViewContainer: '[data-type=container]',

        initialize: function initialize (options) {
            this.about = options.about;
        },

        onRender: function onRender () {
        },

        childViewOptions: function childViewOptions () {
            return {
                structure_name: this.collection.structure.get('name')
            }
        },

        serializeData: function serializeData () {
            return {
                new_comments_path: Routes.new_structure_comment_path(this.collection.structure.get('slug')),
                about            : this.about,
                has_comments     : this.collection.structure.get('has_comments')
            }
        },
    });
});
