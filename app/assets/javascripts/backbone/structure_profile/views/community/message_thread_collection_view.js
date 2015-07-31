StructureProfile.module('Views.Community', function(Module, App, Backbone, Marionette, $, _, undefined) {
    Module.MessageThreadCollectionView = Marionette.CompositeView.extend({
        childView: Module.MessageThreadView,
        template: Module.templateDirname() + 'message_thread_collection_view',
        childViewContainer: '[data-type=container]',

        initialize: function initialize (options) {
            this.about = options.about;
            this.thread_count = options.community_thread_count || 0;
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
                about: this.about,
                thread_count: this.thread_count,
                url: Routes.structure_community_message_threads_path(this.collection.structure.get('slug')),
            }
        },
    });
});
