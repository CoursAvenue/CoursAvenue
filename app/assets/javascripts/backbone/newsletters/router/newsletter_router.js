Newsletter.module('Router', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterRouter = Backbone.Router.extend({
        routes: {
            'choose_layout': 'chooseLayout',
            'new':           'edit',
            'edit':          'edit',
            'mailing_list':  'setMailingList',
            'metadata':      'setMetadata',
            'preview':       'showPreview'
        },

        // TODO:
        // - Before route: Empty layout
        // - After route : setCurrentTab.
        initialize: function initialize (options) {
            this.model = options.model;

            _.bindAll(this, 'saveLayout', 'setLayout',
                      'chooseLayout', 'edit');
        },

        // Save the layout in the router.
        saveLayout: function saveLayout (layout) {
            this.layout = layout;
        },

        ///////////////////////////////////////////////////////////////////////////////////////

        // Update the layout in the model.
        setLayout: function setLayout (data) {
            console.log(data);
        },

        ///////////////////////////////////////////////////////////////////////////////////////

        // Route: /choose_layout
        chooseLayout: function chooseLayout () {
            this.layout.setCurrentTab('choose_layout');

            var bootstrap = window.coursavenue.bootstrap;

            var layouts_collection = new Newsletter.Models.LayoutsCollection(bootstrap.models.layouts);
            var layouts_collection_view = new Newsletter.Views.LayoutsCollectionView({
                collection: layouts_collection
            });

            this.layout.showWidget(layouts_collection_view);
        },

        // Route: /edit
        edit: function edit () {
            this.layout.setCurrentTab('new');

            var bloc_collection = new Newsletter.Models.BlocsCollection(this.model.get('blocs'))
            var edition_view = new Newsletter.Views.EditionView({
                model: this.model,
                collection: bloc_collection
            });

            this.layout.showWidget(edition_view);
        },

        // Route: /mailing_list
        setMailingList: function setMailingList () {
            this.layout.setCurrentTab('mailing_list');

            console.log('setMailingList');
        },

        // Route: /metadata
        setMetadata: function setMetadata () {
            this.layout.setCurrentTab('metadata');

            console.log('setMetadata');
        },

        // Route: /preview
        showPreview: function showPreview () {
            this.layout.setCurrentTab('preview');

            console.log('showPreview');
        },
    });
});
