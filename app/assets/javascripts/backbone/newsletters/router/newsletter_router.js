Newsletter.module('Router', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterRouter = Backbone.Router.extend({
        routes: {
            'choose_layout': 'setLayout',
            'new':           'setModel',
            'mailing_list':  'setMailingList',
            'metadata':      'setMetadata',
            'preview':       'showPreview'
        },

        initialize: function initialize (options) {
            this.model = options.model;

            _.bindAll(this, 'saveLayout', 'setLayout');
        },

        saveLayout: function saveLayout (layout) {
            this.layout = layout;
        },

        ///////////////////////////////////////////////////////////////////////////////////////

        setLayout: function setLayout () {
            var bootstrap = window.coursavenue.bootstrap;

            var layouts_collection = new Newsletter.Models.LayoutsCollection(bootstrap.models.layouts);
            var layouts_collection_view = new Newsletter.Views.LayoutsCollectionView({
                collection: layouts_collection
            });

            this.layout.showWidget(layouts_collection_view);
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
