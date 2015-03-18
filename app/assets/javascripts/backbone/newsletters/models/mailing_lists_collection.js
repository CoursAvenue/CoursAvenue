Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsCollection = Backbone.Collection.extend({
        model: Module.MailingList,
    });
});
