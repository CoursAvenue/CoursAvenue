StructureProfile.module('Views.Community', function(Module, App, Backbone, Marionette, $, _, undefined) {
    Module.MessageThreadView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'message_thread_view',

        initialize: function initialize () {
        },
    });
});
