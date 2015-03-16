Newsletter.module('Router', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterRouter = Backbone.Router.extend({
        routes: {
            'choose_layout': 'setLayout',
            'new': 'setModel',
            'mailing_list': 'setMailingList',
            'metadata': 'setMetadata',
            'preview': 'showPreview'
        },

        setLayout: function setLayout () {
            console.log('setLayout');
        },

        setModel: function newModel () {
            console.log('newModel');
        },

        setMailingList: function setMailingList () {
            console.log('setMailingList');
        },

        setMetadata: function setMetadata () {
            console.log('setMetadata');
        },

        showPreview: function showPreview () {
            console.log('showPreview');
        },
    });
});
