StructureProfile.module('Models.Community', function(Module, App, Backbone, Marionette, $, _) {
    Module.MessageThread = Backbone.Model.extend({
        initialize: function initialize () {
            // TODO: Turn this into a model ?
            this.messages = this.get('messages');
        },
    });

    Module.MessageThreadCollection = Backbone.Collection.extend({
        model: Module.MessageThread,

        initialize: function initialize (models, options) {
            this.options = options;
            this.fetch();
        },

        url: function url () {
            return Routes.structure_community_message_threads_path(this.options.structure_id);
        },
    });
});
